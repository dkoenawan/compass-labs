#!/usr/bin/env bash
# install-schedule.sh
# Installs the weekly triage schedule for one repository in the user's
# crontab (REQ-019), refusing if the repository already has one (REQ-021).
#
# Usage:
#   install-schedule.sh <repo> --day D --time HH:MM --tz ZONE
#
#   --day D       sun..sat (or the full name), or 0..6 with 0 = Sunday
#   --time HH:MM  local time, 24-hour
#   --tz ZONE     IANA time zone, e.g. Pacific/Auckland
#
# Example:
#   install-schedule.sh /path/to/repo --day sat --time 01:00 --tz Pacific/Auckland
#
# Cron runs in the machine's zone (usually UTC) and Debian/Ubuntu cron ignores
# CRON_TZ, so the local day and time are converted to every UTC (minute, hour,
# weekday) they map to on 53 weekly dates over the next year (D3). One cron
# line is written per distinct slot; run-scheduled.sh guards on the local day
# and time, so only the right slot runs. Each line sets TRIAGE_CLAUDE_BIN and
# TRIAGE_GH_BIN to the binaries found now, because cron's PATH is minimal, and
# ends with the marker "# compass-labs:triage: <repo>", which
# uninstall-schedule.sh removes by. Every other crontab line is left as is.
#
# Before writing: validates the arguments, checks `gh auth status`, refuses a
# second schedule for the repo, and creates the triage label (REQ-030).
# TRIAGE_NOW (any `date -d` string) stands in for the clock in tests.

set -euo pipefail

SCRIPT_NAME="install-schedule.sh"
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNNER="$SCRIPTS_DIR/run-scheduled.sh"
DAY_NAMES=(sun mon tue wed thu fri sat)

die() { echo "[$SCRIPT_NAME] Error: $*" >&2; exit 1; }

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
    -h|--help) sed -n '2,29p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) die "unknown option '$1'" ;;
    *) [[ -z "$REPO" ]] || die "unexpected argument '$1'"; REPO="$1"; shift ;;
  esac
done
[[ -n "$REPO" && -n "$DAY" && -n "$TIME" && -n "$ZONE" ]] \
  || die "usage: $SCRIPT_NAME <repo> --day D --time HH:MM --tz ZONE"

# --- Validate -------------------------------------------------------------

DAY_NUM="$(day_number "$DAY")" || die "invalid --day '$DAY' (sun..sat, or 0..6 with 0 = Sunday)"
DAY_NAME="${DAY_NAMES[$DAY_NUM]}"
[[ "$TIME" =~ ^([01][0-9]|2[0-3]):[0-5][0-9]$ ]] || die "invalid --time '$TIME' (HH:MM, 24-hour)"
ZONEINFO="${TZDIR:-/usr/share/zoneinfo}"
[[ "$ZONE" =~ ^[A-Za-z0-9_+-]+(/[A-Za-z0-9_+-]+)*$ && -f "$ZONEINFO/$ZONE" ]] \
  || die "unknown time zone '$ZONE' (no $ZONEINFO/$ZONE)"
TZ="$ZONE" date >/dev/null 2>&1 || die "time zone '$ZONE' doesn't work with date"

[[ -d "$REPO" ]] || die "'$REPO' is not a directory"
REPO_ABS="$(cd "$REPO" && pwd)"
git -C "$REPO_ABS" rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "'$REPO_ABS' is not a git repository"

# resolve_bin <name> <override>: an absolute path for the cron line.
resolve_bin() {
  local name="$1" override="$2" found
  if [[ -n "$override" ]]; then
    [[ -x "$override" && ! -d "$override" ]] || die "$name not found: '$override' is not an executable file"
    found="$override"
  else
    found="$(command -v "$name" 2>/dev/null)" || die "$name not found on PATH"
  fi
  realpath "$found"
}
CLAUDE_BIN="$(resolve_bin claude "${TRIAGE_CLAUDE_BIN:-}")"
GH_BIN="$(resolve_bin gh "${TRIAGE_GH_BIN:-}")"

# Cron treats % as a newline, and the line is run by /bin/sh with single quotes.
for p in "$REPO_ABS" "$CLAUDE_BIN" "$GH_BIN" "$RUNNER"; do
  [[ "$p" != *[%\'$'\n']* ]] || die "path '$p' contains %, a single quote or a newline, which a cron line can't hold"
done

(cd "$REPO_ABS" && "$GH_BIN" auth status >/dev/null 2>&1) \
  || die "gh is not authenticated ('$GH_BIN auth status' failed). Run 'gh auth login' first: a scheduled run needs stored credentials, not a shell-only GH_TOKEN"

# --- Refuse a second schedule (REQ-021) -----------------------------------

MARKER="# compass-labs:triage: $REPO_ABS"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
CURRENT="$WORK/current"
crontab -l >"$CURRENT" 2>/dev/null || : >"$CURRENT"

existing="$(MARKER="$MARKER" awk '{ m = ENVIRON["MARKER"]; if (length($0) >= length(m) && substr($0, length($0) - length(m) + 1) == m) print }' "$CURRENT")"
if [[ -n "$existing" ]]; then
  echo "[$SCRIPT_NAME] Error: $REPO_ABS already has a triage schedule. The crontab is unchanged:" >&2
  echo "$existing" >&2
  echo "[$SCRIPT_NAME] Run uninstall-schedule.sh $REPO_ABS first to replace it." >&2
  exit 1
fi

# --- The triage label (REQ-030) -------------------------------------------

TRIAGE_GH_BIN="$GH_BIN" "$BASH" "$SCRIPTS_DIR/ensure-label.sh" "$REPO_ABS" \
  || die "could not make sure the 'triage' label exists; nothing installed"

# --- UTC slots over the next year (D3) ------------------------------------

if [[ -n "${TRIAGE_NOW:-}" ]]; then
  NOW="$(date -u -d "$TRIAGE_NOW" +%s)" || die "invalid TRIAGE_NOW '$TRIAGE_NOW'"
else
  NOW="$(date +%s)"
fi
TODAY="$(TZ="$ZONE" date -d "@$NOW" +%F)"
FIRST=""
for k in 0 1 2 3 4 5 6; do
  d="$(date -u -d "$TODAY + $k days" +%F)"
  if [[ "$(date -u -d "$d" +%w)" == "$DAY_NUM" ]]; then FIRST="$d"; break; fi
done

SLOTS="$WORK/slots"
: >"$SLOTS"
NEXT=""
gaps=()
for i in $(seq 0 52); do
  d="$(date -u -d "$FIRST + $((7 * i)) days" +%F)"
  if epoch="$(date -d "TZ=\"$ZONE\" $d $TIME" +%s 2>/dev/null)" \
     && [[ "$(TZ="$ZONE" date -d "@$epoch" '+%F %H:%M')" == "$d $TIME" ]]; then
    date -u -d "@$epoch" '+%-M %-H %w' >>"$SLOTS"
    if [[ -z "$NEXT" && "$epoch" -gt "$NOW" ]]; then NEXT="$epoch"; fi
  else
    gaps+=("$d")
  fi
done
mapfile -t TUPLES < <(sort -u "$SLOTS" | sort -k3,3n -k2,2n -k1,1n)
[[ ${#TUPLES[@]} -gt 0 ]] || die "$DAY_NAME $TIME never exists in $ZONE"

# --- Write ------------------------------------------------------------------

NEW="$WORK/new"
cp "$CURRENT" "$NEW"
if [[ -s "$NEW" && "$(tail -c 1 "$NEW" | od -An -c | tr -d ' ')" != '\n' ]]; then
  echo >>"$NEW"
fi
LINES=()
for tuple in "${TUPLES[@]}"; do
  read -r m h w <<<"$tuple"
  line="$m $h * * $w TRIAGE_CLAUDE_BIN='$CLAUDE_BIN' TRIAGE_GH_BIN='$GH_BIN' /bin/bash '$RUNNER' '$REPO_ABS' --day $DAY_NAME --time $TIME --tz $ZONE $MARKER"
  LINES+=("$line")
  echo "$line" >>"$NEW"
done
crontab - <"$NEW" || die "crontab failed to install the schedule"

echo "[$SCRIPT_NAME] Installed the triage schedule for $REPO_ABS: $DAY_NAME $TIME $ZONE."
echo "[$SCRIPT_NAME] Cron lines (UTC):"
printf '  %s\n' "${LINES[@]}"
for g in "${gaps[@]}"; do
  echo "[$SCRIPT_NAME] Warning: $TIME on $g doesn't exist in $ZONE (a daylight-saving gap); that week's run is skipped." >&2
done
if [[ -n "$NEXT" ]]; then
  echo "[$SCRIPT_NAME] Next run: $(TZ="$ZONE" date -d "@$NEXT" '+%a %F %H:%M %Z') ($ZONE)."
fi
echo "[$SCRIPT_NAME] Run log: \${XDG_STATE_HOME:-\$HOME/.local/state}/compass-labs/triage/$(sed -e 's|^/||' -e 's|/|-|g' <<<"$REPO_ABS")/"
echo "[$SCRIPT_NAME] Uninstall: bash $SCRIPTS_DIR/uninstall-schedule.sh $REPO_ABS"
