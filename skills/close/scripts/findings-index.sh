#!/usr/bin/env bash
# findings-index.sh <repo>
# Rebuilds docs/findings/index.md from the frontmatter of every
# docs/findings/*.md (except index.md): newest first, one row each, with a
# count per type at the top. Deterministic; plain bash.

set -uo pipefail
repo="${1:?Usage: findings-index.sh <repo>}"
dir="$repo/docs/findings"
mkdir -p "$dir"

field() { sed -n "/^---$/,/^---$/{s/^$2:[[:space:]]*//p}" "$1" | head -1; }

rows=()
declare -A count=([decision]=0 [risk]=0 [learning]=0 [trellis]=0)
shopt -s nullglob
for f in "$dir"/*.md; do
  [[ "$(basename "$f")" == "index.md" ]] && continue
  d="$(field "$f" date)"; t="$(field "$f" type)"; ti="$(field "$f" title)"; pr="$(field "$f" pr)"
  [[ -n "$d" && -n "$t" ]] || continue
  [[ "$t" == compass ]] && t=trellis   # type was renamed in 4.0.0
  [[ -n "${count[$t]+x}" ]] && count[$t]=$((count[$t] + 1))
  rows+=("$d"$'\t'"$t"$'\t'"$ti"$'\t'"$pr"$'\t'"$(basename "$f")")
done

{
  echo "# Findings"
  echo
  echo "> Built by \`skills/close/scripts/findings-index.sh\`. Don't edit by hand."
  echo
  echo "**${count[decision]}** decision · **${count[risk]}** risk · **${count[learning]}** learning · **${count[trellis]}** trellis"
  echo
  echo "| Date | Type | Finding | PR |"
  echo "|---|---|---|---|"
  if [[ ${#rows[@]} -gt 0 ]]; then
    printf '%s\n' "${rows[@]}" | sort -r | while IFS=$'\t' read -r d t ti pr file; do
      echo "| $d | $t | [$ti]($file) | ${pr:-none} |"
    done
  fi
} > "$dir/index.md"
echo "findings-index: ${#rows[@]} findings -> docs/findings/index.md"
