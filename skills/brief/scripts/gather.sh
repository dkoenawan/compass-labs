#!/usr/bin/env bash
# gather.sh <out-dir> [YYYY-MM-DD]
# Read-only snapshot for the weekly brief, for the 7 days ending on the date
# (default today) and the month so far:
#   runs.json      controller log lines (week and month)
#   prs.json       per project: open compass/* PRs, and those merged this week
#   findings.json  per project: findings on the default branch dated this
#                  month (docs/findings/*.md frontmatter), with type
#   meta.json      dates, cadence role this week, projects
set -euo pipefail
SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CTL="$SCRIPTS/../../controller/scripts"
# shellcheck source=../../controller/scripts/lib.sh
source "$CTL/lib.sh"
GH="${GH_BIN:-gh}"
out="${1:?Usage: gather.sh <out-dir> [date]}"; mkdir -p "$out"
end="${2:-$(now_local +%F)}"
start="$(date -d "$end -6 days" +%F)"; month="$(date -d "$end" +%Y-%m)"

if [[ -f "$RUNS_LOG" ]]; then
  jq -s --arg s "$start" --arg e "$end" --arg m "$month" \
    '{week: [.[] | select(.date >= $s and .date <= $e)], month: [.[] | select(.date | startswith($m))]}' "$RUNS_LOG" > "$out/runs.json"
else
  echo '{"week":[],"month":[]}' > "$out/runs.json"
fi

mapfile -t repos < <(jq -r '([.projects[].repo] + [.compass_repo]) | unique | .[]' "$CONTROLLER_CONFIG")
echo '[]' > "$out/prs.json"; echo '[]' > "$out/findings.json"
for r in "${repos[@]}"; do
  [[ -d "$r/.git" ]] || continue
  name="$(basename "$r")"
  role="$(jq -r --arg r "$r" 'if .compass_repo == $r then "compass" else "side" end' "$CONTROLLER_CONFIG")"
  prs="$(cd "$r" && "$GH" pr list --state all --limit 100 --json number,title,url,state,headRefName,mergedAt,createdAt 2>/dev/null || echo '[]')"
  jq --arg n "$name" --arg role "$role" --arg s "$start" --argjson p "$prs" \
    '. + [{project:$n, role:$role,
           open: [$p[] | select(.state=="OPEN" and (.headRefName|startswith("compass/")))],
           merged: [$p[] | select(.state=="MERGED" and (.headRefName|startswith("compass/")) and (.mergedAt[:10] >= $s))]}]' \
    "$out/prs.json" > "$out/prs.tmp" && mv "$out/prs.tmp" "$out/prs.json"
  shopt -s nullglob
  for f in "$r"/docs/findings/*.md; do
    [[ "$(basename "$f")" == index.md ]] && continue
    d="$(sed -n '/^---$/,/^---$/{s/^date:[[:space:]]*//p}' "$f" | head -1)"
    [[ "$d" == "$month"* ]] || continue
    t="$(sed -n '/^---$/,/^---$/{s/^type:[[:space:]]*//p}' "$f" | head -1)"
    ti="$(sed -n '/^---$/,/^---$/{s/^title:[[:space:]]*//p}' "$f" | head -1)"
    jq --arg n "$name" --arg d "$d" --arg t "$t" --arg ti "$ti" --arg f "docs/findings/$(basename "$f")" \
      '. + [{project:$n, date:$d, type:$t, title:$ti, file:$f}]' "$out/findings.json" > "$out/f.tmp" && mv "$out/f.tmp" "$out/findings.json"
  done
done

jq -n --arg s "$start" --arg e "$end" --arg m "$month" --arg role "$(bash "$CTL/cadence.sh" "$end")" \
  --arg next "$(bash "$CTL/cadence.sh" "$(date -d "$end +7 days" +%F)")" \
  '{start:$s, end:$e, month:$m, role:$role, next_role:$next}' > "$out/meta.json"
echo "gather: $out"
