#!/usr/bin/env bash
# pr-drilldown.sh <pr> <repo>
# Puts a collapsed "Drill down" section in the PR body, between
# <!-- compass:drilldown --> and <!-- /compass:drilldown -->: links to the
# brief, findings, decision trail and docs the branch changed. Replaces an
# existing section, otherwise appends it. Touches nothing else in the body.

set -uo pipefail
pr="${1:?Usage: pr-drilldown.sh <pr> <repo>}"
repo="${2:?Usage: pr-drilldown.sh <pr> <repo>}"
GH="${GH_BIN:-gh}"

base="$("$GH" pr view "$pr" --json baseRefName -q .baseRefName)" || { echo "pr-drilldown: can't read PR $pr" >&2; exit 1; }
git -C "$repo" fetch -q origin "$base" 2>/dev/null || true
changed="$(git -C "$repo" diff --name-only "origin/$base...HEAD" 2>/dev/null || git -C "$repo" diff --name-only "$base...HEAD")"

link() { echo "- [\`$1\`]($1)"; }
section() {
  echo "<!-- compass:drilldown -->"
  echo "<details><summary>Drill down</summary>"
  echo
  local kind pattern files
  for kind in "Brief|^docs/briefs/" "Findings|^docs/findings/[^/]*\.md$" "Decision trail|^docs/trails/" "Docs|^docs/(reference|explanation|index\.md)"; do
    pattern="${kind#*|}"
    files="$(grep -E "$pattern" <<<"$changed" | grep -v '^docs/findings/index.md$' || true)"
    [[ -n "$files" ]] || continue
    echo "**${kind%%|*}**"
    while IFS= read -r f; do link "$f"; done <<<"$files"
    echo
  done
  echo "</details>"
  echo "<!-- /compass:drilldown -->"
}

body="$("$GH" pr view "$pr" --json body -q .body)"
new_section="$(section)"
if grep -q '<!-- compass:drilldown -->' <<<"$body"; then
  body="$(awk -v repl="$new_section" '
    /<!-- compass:drilldown -->/ {print repl; skip=1; next}
    /<!-- \/compass:drilldown -->/ {skip=0; next}
    !skip {print}' <<<"$body")"
else
  body="$body"$'\n\n'"$new_section"
fi
printf '%s\n' "$body" | "$GH" pr edit "$pr" --body-file - >/dev/null
echo "pr-drilldown: PR $pr updated"
