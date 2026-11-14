#!/usr/bin/env bash
# run-scheduled.sh
# The cron entry point for a scheduled triage run. install-schedule.sh writes
# one cron line per UTC slot the local day and time map to; this script
# guards on the local day and time, so only the right slot runs (D3).
#
# Usage:
#   run-scheduled.sh <repo> --day D --time HH:MM --tz ZONE
#
#   --day D       sun..sat (or the full name), or 0..6 with 0 = Sunday
#   --time HH:MM  local time, 24-hour
#   --tz ZONE     IANA time zone, e.g. Pacific/Auckland
#
# In order:
#   Guard     the local weekday and HH:MM (TRIAGE_NOW, any `date -d` string,
#             stands in for the clock in tests). Not the installed day and
#             time: exit 0 silently (REQ-019).
#   Log/lock  ${XDG_STATE_HOME:-$HOME/.local/state}/compass-labs/triage/{repo-slug}/
#             {local-date}.log, with the lock directory .lock beside it. Lock
#             held: log it, exit 0.
#   Preflight claude and gh from TRIAGE_CLAUDE_BIN / TRIAGE_GH_BIN, then PATH;
#             jq, git and timeout on PATH; the repo is a git repository;
#             `gh auth status` passes. Any failure: log which and why, exit 1,
#             publish nothing (REQ-022).
#   Snapshot  gather.sh into a mktemp -d directory, removed on exit.
#   Stock-take claude -p, headless, under `timeout 50m`, with the prompt built
#             from reference/stock-take.md. Only the Read, Grep and Glob tools;
#             --restricted (no user, project or local settings files, so no
#             settings hooks or plugins); no MCP servers; no --plugin-dir; never
#             --dangerously-skip-permissions (REQ-012, REQ-025). Stdout is the
#             report.
#   Publish   publish-report.sh with the local date.
#
# This script never runs a gh write itself, never runs an apply (REQ-015),
# and writes no file in the repository (REQ-010). Every step's outcome and
# duration go to the log.

set -uo pipefail

SCRIPT_NAME="run-scheduled.sh"
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPTS_DIR/.." && pwd)"
STOCK_TAKE="$SKILL_DIR/reference/stock-take.md"
CLAUDE_TIMEOUT="50m"

usage_error() { echo "[$SCRIPT_NAME] Error: $*" >&2; exit 2; }

# day_number <day>: prints 0..6 (0 = Sunday), or fails.
day_number() {
  case "$(tr '[:upper:]' '[:lower:]' <<<"$1")" in
    0|sun|sunday) echo 0 ;; 1|mon|monday) echo 1 ;; 2|tue|tuesday) echo 2 ;;
    3|wed|wednesday) echo 3 ;; 4|thu|thursday) echo 4 ;; 5|fri|friday) echo 5 ;;
    6|sat|saturday) echo 6 ;; *) return 1 ;;
  esac
}

REPO="" DAY="" TIME="" ZONE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --day) DAY="${2:-}"; shift 2 || shift $# ;;
    --time) TIME="${2:-}"; shift 2 || shift $# ;;
    --tz) ZONE="${2:-}"; shift 2 || shift $# ;;
    -*) usage_error "unknown option '$1'" ;;
    *) [[ -z "$REPO" ]] || usage_error "unexpected argument '$1'"; REPO="$1"; shift ;;
  esac
done
[[ -n "$REPO" && -n "$DAY" && -n "$TIME" && -n "$ZONE" ]] \
  || usage_error "usage: $SCRIPT_NAME <repo> --day D --time HH:MM --tz ZONE"
DAY_NUM="$(day_number "$DAY")" || usage_error "invalid --day '$DAY'"
[[ "$TIME" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]] || usage_error "invalid --time '$TIME' (HH:MM)"

# --- Guard ----------------------------------------------------------------

if [[ -n "${TRIAGE_NOW:-}" ]]; then
  NOW="$(date -u -d "$TRIAGE_NOW" +%s 2>/dev/null)" || usage_error "invalid TRIAGE_NOW '$TRIAGE_NOW'"
else
  NOW="$(date +%s)"
fi
LOCAL="$(TZ="$ZONE" date -d "@$NOW" '+%w %H:%M %F')"
read -r LOCAL_DOW LOCAL_HM LOCAL_DATE <<<"$LOCAL"
if [[ "$LOCAL_DOW" != "$DAY_NUM" || "$LOCAL_HM" != "$TIME" ]]; then
  exit 0
fi

# --- Log and lock ---------------------------------------------------------

REPO_ABS="$(realpath -m "$REPO")"
SLUG="$(sed -e 's|^/||' -e 's|/|-|g' <<<"$REPO_ABS")"
LOG_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/compass-labs/triage/${SLUG:-root}"
mkdir -p "$LOG_DIR" || { echo "[$SCRIPT_NAME] Error: cannot create log directory $LOG_DIR" >&2; exit 1; }
LOG="$LOG_DIR/$LOCAL_DATE.log"
LOCK="$LOG_DIR/.lock"

log() { echo "[$(date -u '+%Y-%m-%d %H:%M:%S')Z] $*" >>"$LOG"; }
RUN_START=$SECONDS
STEP_START=$SECONDS
step_start() { STEP_START=$SECONDS; log "step $1: started"; }
step_ok() { log "step $1: ok ($((SECONDS - STEP_START))s)"; }
fail() {
  log "step $1: FAILED ($((SECONDS - STEP_START))s): $2"
  log "===== triage run failed after $((SECONDS - RUN_START))s; nothing published ====="
  exit 1
}

if ! mkdir "$LOCK" 2>/dev/null; then
  log "lock $LOCK is held by another run; exiting without running"
  exit 0
fi
WORK=""
cleanup() {
  [[ -n "$WORK" ]] && rm -rf "$WORK"
  rmdir "$LOCK" 2>/dev/null || true
}
trap cleanup EXIT

log "===== triage scheduled run started ====="
log "repo: $REPO_ABS; schedule: $DAY $TIME $ZONE; local now: $LOCAL_DATE $LOCAL_HM"

# --- Preflight ------------------------------------------------------------

step_start preflight
# resolve_bin <name> <override>: prints the binary to use, or fails the step.
resolve_bin() {
  local name="$1" override="$2" var="$3" found
  if [[ -n "$override" ]]; then
    [[ -x "$override" && ! -d "$override" ]] || fail preflight "$name not found: $var=$override is not an executable file"
    echo "$override"
    return
  fi
  found="$(command -v "$name" 2>/dev/null)" \
    || fail preflight "$name not found: $var is not set and $name is not on PATH ($PATH)"
  echo "$found"
}
CLAUDE_BIN="$(resolve_bin claude "${TRIAGE_CLAUDE_BIN:-}" TRIAGE_CLAUDE_BIN)" || exit 1
GH_BIN="$(resolve_bin gh "${TRIAGE_GH_BIN:-}" TRIAGE_GH_BIN)" || exit 1
for tool in jq git timeout; do
  command -v "$tool" >/dev/null 2>&1 || fail preflight "$tool not found on PATH ($PATH)"
done
[[ -d "$REPO_ABS" ]] || fail preflight "repository $REPO_ABS does not exist"
git -C "$REPO_ABS" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || fail preflight "$REPO_ABS is not a git repository"
if ! auth_out="$(cd "$REPO_ABS" && "$GH_BIN" auth status 2>&1)"; then
  reason="gh not authenticated ($GH_BIN auth status failed: $(tr '\n' ' ' <<<"$auth_out"))"
  if [[ -z "${GH_TOKEN:-}" && -z "${GITHUB_TOKEN:-}" ]]; then
    reason="$reason; GH_TOKEN is not in cron's environment, so gh needs credentials stored by 'gh auth login'"
  fi
  fail preflight "$reason"
fi
export TRIAGE_GH_BIN="$GH_BIN"
log "claude: $CLAUDE_BIN; gh: $GH_BIN"
step_ok preflight

# --- Snapshot -------------------------------------------------------------

step_start snapshot
WORK="$(mktemp -d)" || fail snapshot "mktemp -d failed"
SNAP="$WORK/snapshot"
"$BASH" "$SCRIPTS_DIR/gather.sh" "$REPO_ABS" "$SNAP" >>"$LOG" 2>&1 || fail snapshot "gather.sh failed (see above)"
step_ok snapshot

# --- Stock-take -----------------------------------------------------------

step_start stock-take
PROMPT="$WORK/prompt.md"
REPORT="$WORK/report.md"
{
  cat <<EOF
You are running the triage stock-take headless, as a scheduled run with no user present.
The snapshot directory is $SNAP. It holds issues.json, reports.json, merged-prs.json, meta.json and, if the repository has a project anchor, anchor.md.
The current directory is the repository's working tree. Read code with Read, Grep and Glob only.
Follow the procedure below exactly. Your whole output is the report markdown, starting with "## Header", and nothing else.

EOF
  cat "$STOCK_TAKE"
} >"$PROMPT" || fail stock-take "could not build the prompt from $STOCK_TAKE"

# Flags checked against `claude --help` (CLI 2.1.325): see implement/as-built.md.
CLAUDE_ARGS=(
  -p
  --tools "Read,Grep,Glob"
  --restricted
  --strict-mcp-config
  --permission-prompts none
  --disable-slash-commands
  --no-session-persistence
  --output-format text
  --add-dir "$SNAP"
)
(cd "$REPO_ABS" && timeout "$CLAUDE_TIMEOUT" "$CLAUDE_BIN" "${CLAUDE_ARGS[@]}" <"$PROMPT" >"$REPORT" 2>>"$LOG")
rc=$?
if [[ $rc -eq 124 ]]; then
  fail stock-take "claude timed out after $CLAUDE_TIMEOUT"
elif [[ $rc -ne 0 ]]; then
  fail stock-take "claude exited with code $rc"
fi
[[ -s "$REPORT" ]] || fail stock-take "claude printed no report"
step_ok stock-take

# --- Publish --------------------------------------------------------------

step_start publish
"$BASH" "$SCRIPTS_DIR/publish-report.sh" "$REPO_ABS" "$SNAP" "$REPORT" "$LOCAL_DATE" >>"$LOG" 2>&1
rc=$?
if [[ $rc -eq 3 ]]; then
  log "step publish: FAILED ($((SECONDS - STEP_START))s): the report was published, but closing a superseded report failed (see above)"
  log "===== triage run finished with an error after $((SECONDS - RUN_START))s ====="
  exit 1
elif [[ $rc -ne 0 ]]; then
  cp "$REPORT" "$LOG_DIR/$LOCAL_DATE.report.md" 2>/dev/null \
    && log "the unpublished report is kept at $LOG_DIR/$LOCAL_DATE.report.md"
  fail publish "publish-report.sh exited with code $rc (see above)"
fi
step_ok publish

log "===== triage scheduled run finished ok in $((SECONDS - RUN_START))s ====="
exit 0
