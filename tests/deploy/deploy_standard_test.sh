#!/usr/bin/env bash
# deploy_standard_test.sh
# Content assertions for the Deploy standard (#30 DES-001): the skill and
# its two references exist, the seven declaration items each have a named
# field, each tier has its risk and a row for each of the seven release-
# record sections, and the rollback and change-record sections each name a
# framework with a verdict (REQ-001, REQ-014, REQ-016).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

STD="$REPO_ROOT/skills/deploy/SKILL.md"
DECL="$REPO_ROOT/skills/deploy/reference/declaration.md"
FW="$REPO_ROOT/skills/deploy/reference/frameworks.md"
for f in "$STD" "$DECL" "$FW"; do
  [[ -f "$f" ]] || fail "${f#"$REPO_ROOT"/} not found"
done
std="$(cat "$STD")"

# --- 1. Frontmatter: the name, and a description that names the starter ---
assert_contains "$std" $'name: deploy\n' "the standard should declare name: deploy"
desc="$(grep -m1 '^description:' "$STD")"
assert_contains "$desc" "starter" "the description should name the starter, so a request in words loads it"

# --- 2. The seven declaration items each have a named field (REQ-001) ----
for field in 'l1.parts[]' 'l2.steps[]' 'kind: "routine"' 'kind: "production_affecting"' \
  'confirmation.run' '`rollback`' '`release_mode`'; do
  assert_contains "$std" "$field" "the standard's item table should name $field"
done
assert_contains "$std" '"deployment": "none"' "the standard should name the nothing-to-deploy declaration"
# The reference gives a full example for each mode, and each parses as JSON.
for mode in '"release_mode": "in_session"' '"release_mode": "own_session"' '"deployment": "none"'; do
  assert_contains "$(cat "$DECL")" "$mode" "declaration.md should have an example with $mode"
done
n=0
while IFS= read -r block; do
  [[ -z "$block" ]] && continue
  jq -e . >/dev/null 2>&1 <<<"$block" || fail "an example in declaration.md isn't valid JSON"
  n=$((n + 1))
done < <(awk '/^```json$/{on=1; buf=""; next} /^```$/{if(on){gsub(/\n/," ",buf); print buf}; on=0; next} on{buf=buf $0 "\n"}' "$DECL")
[[ $n -ge 3 ]] || fail "declaration.md should have at least three JSON examples (found $n)"

# --- 3. Tiers: each has its risk, and a row for each section (REQ-014) ---
for tier in skip short full; do
  grep -qE "^\| \*\*$tier\*\* \| .+ \|$" "$STD" || fail "the risk table should give the risk for tier '$tier'"
done
SECTIONS=("Lifecycles run and why" "Release strategy" "Completeness" "Steps run" \
  "Confirmation" "Rollback" "Change record")
for s in "${SECTIONS[@]}"; do
  row="$(grep -E "^\| $s \| " "$STD" | head -1)"
  [[ -n "$row" ]] || fail "the tier table should have a row for '$s'"
  cells="$(awk -F'|' '{print NF-2}' <<<"$row")"
  assert_eq 4 "$cells" "the '$s' row should have a cell for each of the three tiers"
done

# --- 4. Frameworks: rollback and change record name one with a verdict ---
for s in "Rollback" "Change record"; do
  grep -qE "^\| $s \| [^|]+ \| (adopt|adapt|reject) \| [^|]+ \|$" "$FW" \
    || fail "frameworks.md should name a framework with a verdict and reason for '$s'"
done
# Every section of the release record has at least one framework row.
for s in "${SECTIONS[@]}"; do
  grep -qE "^\| $s \| " "$FW" || fail "frameworks.md should cover the '$s' section"
done

echo "ok: Deploy standard content checked"
exit 0
