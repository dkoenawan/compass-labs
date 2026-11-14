#!/usr/bin/env bash
# ensure-label.sh
# Creates the `triage` label in a repository if it doesn't exist (REQ-030).
# Called only by install-schedule.sh and the interactive apply, never by a
# scheduled run (REQ-029: a scheduled run creates no label).
#
# Usage:
#   ensure-label.sh <repo>
#
# Exits 0 when the label exists or was created, non-zero with the reason
# otherwise. The gh binary is TRIAGE_GH_BIN if set, else gh on PATH.

set -euo pipefail

SCRIPT_NAME="ensure-label.sh"
die() { echo "[$SCRIPT_NAME] Error: $*" >&2; exit 1; }

REPO="${1:-}"
[[ -n "$REPO" ]] || die "usage: $SCRIPT_NAME <repo>"
[[ -d "$REPO" ]] || die "'$REPO' is not a directory"
command -v jq >/dev/null 2>&1 || die "jq not found"
GH="${TRIAGE_GH_BIN:-gh}"
command -v "$GH" >/dev/null 2>&1 || die "gh not found ($GH)"
cd "$REPO"

labels="$("$GH" label list --limit 1000 --json name)" || die "could not list labels (gh label list failed)"
if jq -e 'any(.[]; .name == "triage")' <<<"$labels" >/dev/null; then
  echo "[$SCRIPT_NAME] Label 'triage' exists."
  exit 0
fi

"$GH" label create triage --description "Triage report" >/dev/null \
  || die "could not create the 'triage' label (gh label create failed)"
echo "[$SCRIPT_NAME] Created label 'triage'."
