#!/usr/bin/env bash
# session-commit-guard.sh
# Stop hook (D8, REQ-016). For every docs/sessions/*/log.md (never
# docs/sessions/archive/), checks whether it has an uncommitted `decision`
# or `milestone` entry heading (### … — decision: … / ### … — milestone:
# …) among its uncommitted changes. If so, exits 2 — blocking the stop —
# with a reason telling Claude to commit that entry together with the
# artifact changes it describes, per D8/`.claude/rules/compass-sessions.md`.
#
# Loop guard: this hook keys a per-Claude-session block counter (by
# `session_id` from the hook input) in a state file under
# ${TMPDIR:-/tmp}. After 2 consecutive blocks for the same session, the
# 3rd check allows the stop anyway (with a warning on stderr) rather than
# blocking forever — there is no documented `stop_hook_active`-style
# field in the Stop hook's input to detect "this is a hook-forced
# continuation" (checked; see the commit message / tasks.md), so a
# same-session consecutive-block counter is the only loop guard
# available. The counter resets to 0 as soon as a check finds nothing to
# block.
#
# Fails OPEN (exit 0) if this isn't a git repository, or if jq is
# missing — this hook must never be the reason a public install of this
# plugin can't function.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/session-log.sh
source "$SCRIPT_DIR/lib/session-log.sh"

input="$(cat)"

if ! command -v jq >/dev/null 2>&1; then
  echo "[session-commit-guard] WARNING: jq not found — allowing stop (fail open)" >&2
  exit 0
fi

session_id="$(jq -r '.session_id // empty' <<<"$input" 2>/dev/null)"
cwd="$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null)"
[[ -n "$cwd" ]] || cwd="$(pwd)"

# Checked (per task 14): the Stop hook input documented for this CLI does
# not include a stop_hook_active-style field the way some other agent
# frameworks' stop hooks do — there's no signal here for "this stop was
# already forced to continue once." If a future CLI version adds one,
# prefer it over the counter below (skip straight to "allow" when it's
# true) rather than double-counting.
stop_hook_active="$(jq -r '.stop_hook_active // empty' <<<"$input" 2>/dev/null)"

repo_root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  # Not a git repo — nothing to check against, fail open.
  exit 0
fi

state_dir="${TMPDIR:-/tmp}/compass-session-commit-guard"
mkdir -p "$state_dir" 2>/dev/null || true
state_file="$state_dir/${session_id:-unknown}.count"

read_count() {
  [[ -f "$state_file" ]] && cat "$state_file" 2>/dev/null || echo 0
}

sessions_dir="$repo_root/docs/sessions"
found_uncommitted=false
found_paths=()

if [[ -d "$sessions_dir" ]]; then
  for log_path in "$sessions_dir"/*/log.md; do
    [[ -f "$log_path" ]] || continue
    case "$log_path" in
      "$sessions_dir"/archive/*) continue ;;
    esac

    if session_log_has_uncommitted_heading "$repo_root" "$log_path" '— (decision|milestone):'; then
      found_uncommitted=true
      found_paths+=("${log_path#"$repo_root"/}")
    fi
  done
fi

if [[ "$found_uncommitted" != true ]]; then
  # Nothing to block on — reset the loop-guard counter and allow the stop.
  rm -f "$state_file" 2>/dev/null || true
  exit 0
fi

if [[ "$stop_hook_active" == "true" ]]; then
  # A documented re-entrancy signal, if this CLI ever adds one: trust it
  # over the counter rather than blocking again.
  exit 0
fi

count="$(read_count)"
[[ "$count" =~ ^[0-9]+$ ]] || count=0
new_count=$((count + 1))

if [[ "$new_count" -gt 2 ]]; then
  echo "[session-commit-guard] WARNING: allowing the stop after $count consecutive blocks for this session — an uncommitted decision/milestone entry is still present in: ${found_paths[*]}. Commit it manually." >&2
  rm -f "$state_file" 2>/dev/null || true
  exit 0
fi

echo "$new_count" > "$state_file" 2>/dev/null || true

echo "[session-commit-guard] BLOCKED: uncommitted decision/milestone entry in: ${found_paths[*]}. Per D8/.claude/rules/compass-sessions.md, commit the log entry together with the artifact changes it describes before ending this turn." >&2
exit 2
