#!/usr/bin/env bash
# run.sh [--dry-run] [--force]
# One controller run (ADR-012). Cron starts it every hour; it acts only in a
# configured local time slot, at most runs_per_day times a day.
#
#   1. Cadence: in the last 7 days of the month the target is compass_repo
#      (the trellis week); otherwise one of the side projects, rotating by day.
#   2. Task: the oldest open issue labelled `label` without an open
#      trellis/<n>-* PR (pick-task.sh). None: log "idle" and stop.
#   3. Branch trellis/<n>-<slug> from the default branch, in a clean tree.
#   4. In parallel: the problem brief (/trellis:problem-statement) and
#      the pstack run (/pstack:poteto-mode + reference/run-rule.md), which
#      pushes the branch and opens the PR. Then /trellis:close folds it
#      into docs and findings and adds the PR's drill-down.
#   0. On brief_day, the first slot publishes the weekly brief
#      (skills/brief), with no model call.
#   5. One JSON line per outcome in $RUNS_LOG (date, role, repo, issue, PR,
#      exit codes, output tokens, minutes), read by the weekly brief.
#
# --dry-run prints the plan and changes nothing. --force ignores the slot
# and the daily limit. The merge guard (hooks/merge-guard.sh) is active in
# every claude call, because the plugin is loaded. TRELLIS_NOW stands in for
# the clock, and CLAUDE_BIN / GH_BIN for the binaries (tests, cron).

set -uo pipefail
SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPTS/../../.." && pwd)"
# shellcheck source=lib.sh
source "$SCRIPTS/lib.sh"
CLAUDE="${CLAUDE_BIN:-claude}"
GH="${GH_BIN:-gh}"
export GH_BIN="$GH"

dry=0 force=0
for a in "$@"; do case "$a" in --dry-run) dry=1 ;; --force) force=1 ;; *) echo "usage: run.sh [--dry-run] [--force]" >&2; exit 64 ;; esac; done

die() { echo "[controller] $*" >&2; exit 1; }
[[ -f "$CONTROLLER_CONFIG" ]] || die "no config at $CONTROLLER_CONFIG (copy skills/controller/templates/controller.json there)"
command -v jq >/dev/null || die "jq is required"
mkdir -p "$CONTROLLER_STATE"

today="$(now_local +%F)"
hour="$(now_local +%H)"
log_event() { # status, then key=value pairs (values are strings or numbers)
  local status="$1"; shift
  local args=(--arg date "$today" --arg status "$status" --arg at "$(now_local +%FT%T%z)")
  local expr='{date:$date, at:$at, status:$status'
  local kv k v
  for kv in "$@"; do k="${kv%%=*}"; v="${kv#*=}"; args+=(--arg "$k" "$v"); expr+=", $k:(\$$k|tonumber? // \$$k)"; done
  jq -nc "${args[@]}" "$expr}" >> "$RUNS_LOG"
}

# 1. Slot and daily limit.
if [[ $force -eq 0 ]]; then
  jq -r '.slots[]' "$CONTROLLER_CONFIG" | cut -d: -f1 | grep -qx "$hour" || exit 0
  # The weekly brief: on brief_day, once, before any run (no model call).
  if [[ "$(now_local +%a | tr '[:upper:]' '[:lower:]')" == "$(cfg .brief_day)" ]] && ! grep -q "\"date\":\"$today\",[^}]*\"status\":\"brief\"" "$RUNS_LOG" 2>/dev/null; then
    snap="$CONTROLLER_STATE/brief-$today"
    if bash "$PLUGIN_ROOT/skills/brief/scripts/gather.sh" "$snap" "$today" >/dev/null \
       && bash "$PLUGIN_ROOT/skills/brief/scripts/render.sh" "$snap" > "$snap/brief.md" \
       && url="$(bash "$PLUGIN_ROOT/skills/brief/scripts/publish.sh" "$snap/brief.md" "$today")"; then
      log_event brief url="$url"
    else
      log_event failed reason="weekly brief"
    fi
  fi
  done_today="$(grep -c "\"date\":\"$today\",[^}]*\"status\":\"\(ran\|failed\)\"" "$RUNS_LOG" 2>/dev/null || true)"
  if (( ${done_today:-0} >= $(cfg .runs_per_day) )); then
    log_event skipped reason="daily limit reached"; exit 0
  fi
fi

# 2. Cadence and target repo.
role="$(bash "$SCRIPTS/cadence.sh" "$today")"
if [[ "$role" == "compass" ]]; then
  repo="$(cfg .compass_repo)"
else
  mapfile -t sides < <(jq -r '.projects[] | select(.role=="side") | .repo' "$CONTROLLER_CONFIG")
  [[ ${#sides[@]} -gt 0 ]] || { log_event skipped role="$role" reason="no side project configured"; exit 0; }
  repo="${sides[$(( $(date -d "$today" +%-j) % ${#sides[@]} ))]}"
fi
[[ -d "$repo/.git" ]] || { log_event failed role="$role" repo="$repo" reason="not a git repository"; exit 1; }

# 3. Task.
task="$(bash "$SCRIPTS/pick-task.sh" "$repo" "$(cfg .label)")"
if [[ -z "$task" ]]; then log_event idle role="$role" repo="$repo"; exit 0; fi
issue="${task%%$'\t'*}"; title="${task#*$'\t'}"
slug="$(tr '[:upper:]' '[:lower:]' <<<"$title" | tr -cs 'a-z0-9' '-' | sed 's/^-//; s/-$//' | cut -d- -f1-5)"
branch="trellis/$issue-$slug"
trail="docs/trails/$today-$issue-$slug.tsv"

if [[ $dry -eq 1 ]]; then
  jq -n --arg role "$role" --arg repo "$repo" --arg issue "$issue" --arg title "$title" --arg branch "$branch" --arg trail "$trail" \
    '{role:$role, repo:$repo, issue:($issue|tonumber), title:$title, branch:$branch, trail:$trail, steps:["brief ∥ pstack","close"]}'
  exit 0
fi

if [[ -n "$(git -C "$repo" status --porcelain)" ]]; then
  log_event skipped role="$role" repo="$repo" issue="$issue" reason="working tree not clean"; exit 0
fi
default="$(bash "$PLUGIN_ROOT/hooks/lib/default-branch.sh" "$repo" 2>/dev/null)" || { log_event failed role="$role" repo="$repo" issue="$issue" reason="no default branch"; exit 1; }
orig="$(git -C "$repo" symbolic-ref --quiet --short HEAD || echo "$default")"
git -C "$repo" fetch -q origin "$default" || true
if git -C "$repo" rev-parse -q --verify "refs/heads/$branch" >/dev/null; then
  git -C "$repo" switch -q "$branch"
else
  git -C "$repo" switch -q -c "$branch" "origin/$default" 2>/dev/null || git -C "$repo" switch -q -c "$branch" "$default"
fi

# 4. Brief ∥ pstack, then close.
run_dir="$CONTROLLER_STATE/runs/$today-$(basename "$repo")-$issue"
mkdir -p "$run_dir"
rule="$(sed -e "s|{issue}|$issue|g" -e "s|{repo}|$(basename "$repo")|g" -e "s|{branch}|$branch|g" -e "s|{trail}|$trail|g" "$PLUGIN_ROOT/skills/controller/reference/run-rule.md")"
rule="${rule//\{title\}/$title}"
flags=(--model "$(cfg .model)" --permission-mode acceptEdits
       --allowedTools "Bash,Read,Edit,Write,Glob,Grep,Agent,TodoWrite,Skill"
       --output-format stream-json --verbose)
max="$(cfg .max_minutes)"
start=$(date +%s)

(cd "$repo" && timeout 15m "$CLAUDE" -p "/trellis:problem-statement #$issue (branch $branch). Unattended: don't ask, write the brief file only." "${flags[@]}" </dev/null >"$run_dir/brief.jsonl" 2>"$run_dir/brief.err") &
brief_pid=$!
(cd "$repo" && timeout "${max}m" "$CLAUDE" -p "/pstack:poteto-mode $rule" "${flags[@]}" </dev/null >"$run_dir/pstack.jsonl" 2>"$run_dir/pstack.err")
pstack_exit=$?
wait "$brief_pid"; brief_exit=$?
(cd "$repo" && timeout 20m "$CLAUDE" -p "/trellis:close $branch. Unattended: don't ask." "${flags[@]}" </dev/null >"$run_dir/close.jsonl" 2>"$run_dir/close.err")
close_exit=$?
minutes=$(( ($(date +%s) - start + 59) / 60 ))

pr="$(cd "$repo" && "$GH" pr list --head "$branch" --state all --json number -q '.[0].number' 2>/dev/null || true)"
tokens="$(cat "$run_dir"/*.jsonl 2>/dev/null | jq -s '[.[] | select(.type=="result") | (.modelUsage // {}) | to_entries[] | .value.outputTokens // 0] | add // 0' 2>/dev/null || echo 0)"
status=ran
[[ $pstack_exit -eq 0 && -n "$pr" ]] || status=failed
log_event "$status" role="$role" repo="$repo" issue="$issue" branch="$branch" pr="${pr:-none}" \
  pstack_exit="$pstack_exit" brief_exit="$brief_exit" close_exit="$close_exit" output_tokens="$tokens" minutes="$minutes" run_dir="$run_dir"

# Leave the user's checkout as it was, when that's safe.
[[ -z "$(git -C "$repo" status --porcelain)" ]] && git -C "$repo" switch -q "$orig" 2>/dev/null || true
[[ "$status" == ran ]]
