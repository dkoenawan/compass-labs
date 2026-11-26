#!/usr/bin/env bash
# render.sh <snapshot-dir>
# Prints the weekly brief as GitHub markdown: your call first, then the
# month's side/compass split (target 3:1) as a Mermaid pie, a table per
# project, usage, findings, and the run log in a collapsed appendix.
set -euo pipefail
d="${1:?Usage: render.sh <snapshot-dir>}"
m="$d/meta.json"; r="$d/runs.json"; p="$d/prs.json"; f="$d/findings.json"
end="$(jq -r .end "$m")"; start="$(jq -r .start "$m")"

open_n="$(jq '[.[].open[]] | length' "$p")"
ran_side="$(jq '[.month[] | select(.status=="ran" and .role=="side")] | length' "$r")"
ran_comp="$(jq '[.month[] | select(.status=="ran" and .role=="compass")] | length' "$r")"
total=$((ran_side + ran_comp))
if (( total > 0 )); then share=$(( 100 * ran_side / total )); else share=0; fi
if (( total == 0 )); then verdict="no runs yet"; elif (( share >= 70 )); then verdict="on target"; else verdict="below target"; fi

echo "# Compass brief · $start → $end"
echo
echo "**Your call:** $open_n PR(s) to review."
jq -r '.[] | .project as $n | .open[] | "- [\($n) #\(.number)](\(.url)) \(.title)"' "$p"
risk_n="$(jq '[.[] | select(.type=="risk" and .date >= "'"$start"'")] | length' "$f")"
(( risk_n > 0 )) && echo "- ⚠ $risk_n new risk finding(s) below"
echo
echo "This week is a **$(jq -r .role "$m")** week. Next week is **$(jq -r .next_role "$m")**."
echo
echo "## Month so far: side projects vs compass-labs (target 3:1)"
echo
echo '```mermaid'
echo 'pie showData'
echo "  \"Side projects\" : $ran_side"
echo "  \"compass-labs\" : $ran_comp"
echo '```'
echo
echo "**$share%** of this month's runs went to side projects ($verdict; the target is 75%)."
echo
echo "## By project (this week)"
echo
echo "| Project | Role | Runs | Failed / idle | PRs open | Merged |"
echo "|---|---|---|---|---|---|"
jq -r --slurpfile runs "$r" '.[] as $x | ($runs[0].week | map(select(.repo|endswith("/"+$x.project)))) as $w
  | "| \($x.project) | \($x.role) | \([$w[]|select(.status=="ran")]|length) | \([$w[]|select(.status=="failed")]|length) / \([$w[]|select(.status=="idle")]|length) | \($x.open|length) | \($x.merged|length) |"' "$p"
echo
tokens="$(jq '[.week[] | .output_tokens // 0] | add // 0' "$r")"; mins="$(jq '[.week[] | .minutes // 0] | add // 0' "$r")"
echo "**Usage this week:** $tokens output tokens over $mins run-minutes."
echo
echo "## Findings this month"
echo
echo "$(jq '[.[]|select(.type=="decision")]|length' "$f") decision · $(jq '[.[]|select(.type=="risk")]|length' "$f") risk · $(jq '[.[]|select(.type=="learning")]|length' "$f") learning · **$(jq '[.[]|select(.type=="compass")]|length' "$f") compass** (for the compass week)"
echo
jq -r 'sort_by(.date) | reverse | .[:10][] | "- \(.date) · **\(.type)** · \(.project): \(.title) (`\(.file)`)"' "$f"
echo
echo "<details><summary>Appendix: run log this week</summary>"
echo
echo "| Date | Project | Issue | Status | PR | Tokens | Min |"
echo "|---|---|---|---|---|---|---|"
jq -r '.week[] | "| \(.date) | \((.repo // "-")|split("/")|last) | \(.issue // "-") | \(.status) | \(.pr // "-") | \(.output_tokens // "-") | \(.minutes // "-") |"' "$r"
echo
echo "</details>"
