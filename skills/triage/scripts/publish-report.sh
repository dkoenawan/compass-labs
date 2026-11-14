#!/usr/bin/env bash
# publish-report.sh
# Validates a stock-take report and publishes it as one report issue. The
# only script that writes on GitHub in a scheduled run (REQ-010).
#
# Usage:
#   publish-report.sh <repo> <snapshot-dir> <report.md> <date>
#
#   <repo>          Path to the local git repository.
#   <snapshot-dir>  The gather.sh snapshot the report was made from.
#   <report.md>     The report markdown (stock-take.md's report format).
#   <date>          The run's local date, YYYY-MM-DD: the title is "Triage <date>".
#
# In order:
#   1. Validate: every number in issues.json has exactly one "### #n:" entry
#      under exactly one of the six category headings, no other number has
#      one, and the body is at most 65,536 characters. On failure: exit 1
#      with the reason, and no write (REQ-022).
#   2. If "Triage <date>" by the viewer exists in any state: print "already
#      published" and exit 0 (REQ-023).
#   3. If the triage label is missing: prepend a note saying so (REQ-029).
#   4. Create the issue in one call, labelled triage only if the label
#      exists. This script never creates a label (REQ-028, REQ-029).
#   5. Close every other open report in reports.json as not planned, with a
#      comment linking the new one (REQ-011).
# Those are its only write calls. The gh binary is TRIAGE_GH_BIN if set,
# else gh on PATH.
#
# Exit codes: 0 published or already published; 1 invalid report or a gh
# failure before the report was created; 3 published, but closing a
# superseded report failed.

set -euo pipefail

SCRIPT_NAME="publish-report.sh"
MAX_BODY=65536
CATEGORIES=("Covered by merged work" "Direction changed" "Duplicate or cluster"
  "Rewrite or narrow" "Still relevant" "Needs a user decision")

die() { echo "[$SCRIPT_NAME] Error: $*" >&2; exit 1; }
invalid() { echo "[$SCRIPT_NAME] Report invalid, nothing published: $*" >&2; exit 1; }

[[ $# -eq 4 ]] || die "usage: $SCRIPT_NAME <repo> <snapshot-dir> <report.md> <date>"
REPO="$1" SNAP="$2" REPORT="$3" DATE="$4"
[[ -d "$REPO" ]] || die "'$REPO' is not a directory"
[[ "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || die "date '$DATE' is not YYYY-MM-DD"
for f in issues.json reports.json meta.json; do
  [[ -f "$SNAP/$f" ]] || die "snapshot file $SNAP/$f not found"
done
[[ -f "$REPORT" ]] || invalid "report file '$REPORT' not found"
command -v jq >/dev/null 2>&1 || die "jq not found"
GH="${TRIAGE_GH_BIN:-gh}"
command -v "$GH" >/dev/null 2>&1 || die "gh not found ($GH)"

VIEWER="$(jq -r '.viewer' "$SNAP/meta.json")"
LABEL_EXISTS="$(jq -r '.label_exists' "$SNAP/meta.json")"
TITLE="Triage $DATE"

# --- 1. Validate --------------------------------------------------------

is_category() {
  local c
  for c in "${CATEGORIES[@]}"; do [[ "$1" == "$c" ]] && return 0; done
  return 1
}

section="" seen_header=0 seen_actions=0
declare -A seen_cat=() entry=()
lineno=0
while IFS= read -r line || [[ -n "$line" ]]; do
  lineno=$((lineno + 1))
  if [[ "$line" != "###"* && "$line" =~ ^##\ (.*)$ ]]; then
    heading="${BASH_REMATCH[1]}"
    heading="${heading%"${heading##*[![:space:]]}"}"
    if [[ "$heading" == "Header" ]]; then
      [[ $seen_header -eq 0 ]] || invalid "line $lineno: a second '## Header'"
      seen_header=1 section=header
    elif is_category "$heading"; then
      [[ $seen_header -eq 1 ]] || invalid "line $lineno: '## $heading' before '## Header'"
      [[ $seen_actions -eq 0 ]] || invalid "line $lineno: '## $heading' after '## Proposed actions'"
      [[ -z "${seen_cat[$heading]:-}" ]] || invalid "line $lineno: category '## $heading' appears twice"
      seen_cat[$heading]=1 section=category
    elif [[ "$heading" == "Proposed actions" ]]; then
      [[ $seen_header -eq 1 ]] || invalid "line $lineno: '## Proposed actions' before '## Header'"
      [[ $seen_actions -eq 0 ]] || invalid "line $lineno: a second '## Proposed actions'"
      seen_actions=1 section=actions
    else
      invalid "line $lineno: unexpected heading '## $heading'"
    fi
    continue
  fi
  if [[ $seen_header -eq 0 && -n "${line//[[:space:]]/}" ]]; then
    invalid "line $lineno: text before '## Header'"
  fi
  if [[ "$line" =~ ^###\ \#([0-9]+): ]]; then
    n="${BASH_REMATCH[1]}"
    n=$((10#$n))
    [[ "$section" == category ]] || invalid "line $lineno: entry #$n is not under a category heading"
    [[ -z "${entry[$n]:-}" ]] || invalid "issue #$n has more than one entry"
    entry[$n]=1
  fi
done <"$REPORT"

[[ $seen_header -eq 1 ]] || invalid "no '## Header' section"
[[ $seen_actions -eq 1 ]] || invalid "no '## Proposed actions' section"

mapfile -t expected < <(jq -r '.[].number' "$SNAP/issues.json")
declare -A want=()
missing=()
for n in "${expected[@]}"; do
  want[$n]=1
  [[ -n "${entry[$n]:-}" ]] || missing+=("#$n")
done
extra=()
for n in "${!entry[@]}"; do
  [[ -n "${want[$n]:-}" ]] || extra+=("#$n")
done
[[ ${#missing[@]} -eq 0 ]] || invalid "no entry for ${missing[*]}"
[[ ${#extra[@]} -eq 0 ]] || invalid "entries for issues not in the snapshot: ${extra[*]}"

# --- 1 (cont.). Build the body, with step 3's note, and check its length --

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
BODY="$WORK/body.md"
{
  if [[ "$LABEL_EXISTS" != "true" ]]; then
    printf '> **Note:** the `triage` label is missing in this repository, so this report is unlabelled. A scheduled run never creates labels; installing the schedule or running an apply creates it.\n\n'
  fi
  cat "$REPORT"
} >"$BODY"
chars="$(LC_ALL=C.UTF-8 wc -m <"$BODY" | tr -d ' ')"
[[ "$chars" -le $MAX_BODY ]] || invalid "the body is $chars characters, over GitHub's $MAX_BODY"

cd "$REPO"

# --- 2. Already published today? ----------------------------------------

existing="$("$GH" issue list --state all --author "$VIEWER" --search "\"$TITLE\" in:title" \
  --limit 100 --json number,title,author)" || die "gh failed while checking for an existing '$TITLE'"
dup="$(jq -r --arg t "$TITLE" --arg v "$VIEWER" \
  '[.[] | select(.title == $t and .author.login == $v) | .number] | first // empty' <<<"$existing")"
if [[ -n "$dup" ]]; then
  echo "[$SCRIPT_NAME] already published: '$TITLE' is #$dup. Nothing created."
  exit 0
fi

# --- 4. Create ----------------------------------------------------------

create_args=(issue create --title "$TITLE" --body-file "$BODY")
[[ "$LABEL_EXISTS" == "true" ]] && create_args+=(--label triage)
url="$("$GH" "${create_args[@]}")" || die "gh issue create failed; no report published"
NEW="$(grep -oE '/issues/[0-9]+' <<<"$url" | grep -oE '[0-9]+' | tail -1)"
[[ -n "$NEW" ]] || die "gh issue create printed no issue URL ('$url')"
echo "[$SCRIPT_NAME] published #$NEW: $TITLE"

# --- 5. Supersede earlier unapplied reports -----------------------------

status=0
for old in $(jq -r '.[].number' "$SNAP/reports.json"); do
  [[ "$old" == "$NEW" ]] && continue
  if "$GH" issue close "$old" --reason "not planned" --comment "Superseded by #$NEW"; then
    echo "[$SCRIPT_NAME] closed superseded report #$old"
  else
    echo "[$SCRIPT_NAME] Error: published #$NEW but could not close superseded report #$old" >&2
    status=3
  fi
done
exit $status
