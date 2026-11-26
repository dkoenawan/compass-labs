#!/usr/bin/env bash
# pick-task.sh <repo> <label>
# Prints "<number>\t<title>" for the oldest open issue with <label> that has
# no open pull request from a compass/<number>-* branch yet; prints nothing
# when there's no such issue. Read-only.
set -euo pipefail
repo="${1:?Usage: pick-task.sh <repo> <label>}"
label="${2:?Usage: pick-task.sh <repo> <label>}"
GH="${GH_BIN:-gh}"
cd "$repo"
busy="$("$GH" pr list --state open --json headRefName -q '.[].headRefName' | sed -n 's|^compass/\([0-9][0-9]*\)-.*|\1|p')"
"$GH" issue list --state open --label "$label" --limit 100 --json number,title,createdAt \
  -q 'sort_by(.createdAt) | .[] | "\(.number)\t\(.title)"' |
while IFS=$'\t' read -r n t; do
  grep -qx "$n" <<<"$busy" && continue
  printf '%s\t%s\n' "$n" "$t"
  break
done
