#!/usr/bin/env bash
# uninstall-schedule.sh
# Removes a repository's triage schedule from the user's crontab: every line
# ending with the marker "# compass-labs:triage: <repo>". Every other line is
# left byte for byte (REQ-020).
#
# Usage:
#   uninstall-schedule.sh <repo>

set -euo pipefail

SCRIPT_NAME="uninstall-schedule.sh"
die() { echo "[$SCRIPT_NAME] Error: $*" >&2; exit 1; }

REPO="${1:-}"
[[ -n "$REPO" && $# -eq 1 ]] || die "usage: $SCRIPT_NAME <repo>"
if [[ -d "$REPO" ]]; then
  REPO_ABS="$(cd "$REPO" && pwd)"
else
  REPO_ABS="$(realpath -m "$REPO")"   # the repo may be gone; its schedule can still be removed
fi
MARKER="# compass-labs:triage: $REPO_ABS"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
crontab -l >"$WORK/current" 2>/dev/null || : >"$WORK/current"

# Split the crontab into the lines that end with the marker and the rest.
MARKER="$MARKER" awk -v removed="$WORK/removed" '
  { m = ENVIRON["MARKER"]
    if (length($0) >= length(m) && substr($0, length($0) - length(m) + 1) == m) print > removed
    else print }' "$WORK/current" >"$WORK/kept"

if [[ ! -s "$WORK/removed" ]]; then
  echo "[$SCRIPT_NAME] No triage schedule for $REPO_ABS. Nothing to remove; the crontab is unchanged."
  exit 0
fi

crontab - <"$WORK/kept" || die "crontab failed to write the updated crontab"
echo "[$SCRIPT_NAME] Removed the triage schedule for $REPO_ABS:"
sed 's/^/  /' "$WORK/removed"
echo "[$SCRIPT_NAME] Every other crontab line is unchanged."
