#!/usr/bin/env bash
# session-commit-guard.sh
# Stop hook (D8, REQ-016). For every docs/sessions/*/log.md (never
# docs/sessions/archive/), checks whether it has an uncommitted `decision`
# or `milestone` entry heading (### … — decision: … / ### … — milestone:
# …) among its uncommitted changes. If so, exits 2 — blocking the stop —
# with a reason telling Claude to commit that entry together with the
# artifact changes it describes, per D8/`.claude/rules/compass-sessions.md`.
#
# Loop guard (REQ-016 AC: "after 2 blocks in a row, the stop is
# allowed"): a per-Claude-session consecutive-block counter, keyed by
# `session_id`, in a state file under ${TMPDIR:-/tmp}. Blocks 1 and 2
# exit 2; the 3rd consecutive check allows the stop (with a warning on
# stderr) and resets the counter.
#
# `stop_hook_active` (sent by Claude Code — verified on CLI 2.1.282,
# VER-022: false on a normal Stop, true when Claude is continuing because
# a Stop hook blocked) is used only to scope the counter to one turn: on
# `false` the counter restarts at 0, so a block left over from an earlier
# turn never counts against this one. It is deliberately NOT used as an
# "allow" short-circuit: it's a boolean, so honouring it would allow the
# stop after 1 block, not the 2 the acceptance criterion requires. If the
# field is missing (older CLI), the counter alone still caps the loop.
# The counter file is removed on every "allow" path, and counter files
# untouched for over a day (a session that ended mid-sequence) are pruned
# on every run.
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

# true | false | "" (missing). See the loop-guard note above.
stop_hook_active="$(jq -r 'if has("stop_hook_active") then (.stop_hook_active | tostring) else empty end' <<<"$input" 2>/dev/null)"

repo_root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  # Not a git repo — nothing to check against, fail open.
  exit 0
fi

state_dir="${TMPDIR:-/tmp}/compass-session-commit-guard"
mkdir -p "$state_dir" 2>/dev/null || true
state_file="$state_dir/${session_id:-unknown}.count"

# Every "allow" path below removes this session's counter file, so a file
# only outlives its turn if the session ended right after a block (no
# further Stop ever came). Prune those: a counter untouched for a day
# can't belong to a block sequence that's still running (VER-023).
find "$state_dir" -maxdepth 1 -type f -name '*.count' -mmin +1440 -delete 2>/dev/null || true

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

if [[ "$stop_hook_active" == "false" ]]; then
  # A fresh (not hook-forced) stop starts a new block sequence.
  rm -f "$state_file" 2>/dev/null || true
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
