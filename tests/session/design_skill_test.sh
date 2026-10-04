#!/usr/bin/env bash
# design_skill_test.sh
# Checks the Design standard, skills/design/SKILL.md (DES-001 and its
# sections), against the structure the design (#27) requires.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

SKILL_DIR="$REPO_ROOT/skills/design"
SKILL="$SKILL_DIR/SKILL.md"
[[ -f "$SKILL" ]] || fail "skills/design/SKILL.md not found"
content="$(cat "$SKILL")"

# --- Frontmatter -----------------------------------------------------------

[[ "$(head -1 "$SKILL")" == "---" ]] || fail "SKILL.md should start with frontmatter"
frontmatter="$(awk 'NR==1{next} /^---$/{exit} {print}' "$SKILL")"
assert_contains "$frontmatter" "name: design" "frontmatter should name the skill 'design'"
assert_contains "$frontmatter" "description: " "frontmatter should have a description"

# --- Procedure (DES-001) ---------------------------------------------------

assert_contains "$content" "## Procedure" "SKILL.md should have the procedure"
for step in "Read prior knowledge" "Classify the solution and check scope" \
  "Design in depth" "Draw the visuals and the delta" "Check the principles"; do
  assert_contains "$content" "$step" "procedure should have the step '$step'"
done
assert_contains "$content" "primary kind" "procedure should name the primary kind"
assert_contains "$content" "needs_input" "confirmation should go through needs_input"

# --- All-kinds sections ----------------------------------------------------

for section in "Classification" "Scope checklist" "Context view" "Delta list" \
  "Components (DES)" "Decisions" "Principles check" "Risks" "Open questions"; do
  assert_contains "$content" "| $section |" "all-kinds sections should list '$section'"
done

# --- No Design tiers (REQ-032) ---------------------------------------------

assert_contains "$content" "no depth tiers of its own" "SKILL.md should say Design has no tiers"
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  if ! grep -qiE "\b(no|don't|never|not)\b" <<<"$line"; then
    fail "SKILL.md appears to define a Design tier: $line"
  fi
done < <(grep -iE 'design (depth )?tiers?' "$SKILL" || true)

# --- Prior-knowledge rule (DES-002, REQ-035, REQ-036) ------------------------

assert_contains "$content" "## Prior knowledge" "SKILL.md should have the prior-knowledge rule"
for src in "docs/explanation/" "docs/reference/" "docs/registry/"; do
  assert_contains "$content" "$src" "prior knowledge should include $src"
done
assert_contains "$content" "Never read a past session folder" "prior knowledge should forbid past session folders"
assert_contains "$content" "docs/sessions/archive/" "the rule should name the archive explicitly"
assert_contains "$content" "planned_in" "the rule should say to ignore planned_in pointers"
assert_contains "$content" "No project documentation found; designed from the Define output and the code." \
  "the rule should give the no-docs sentence"

# --- On-demand files exist -------------------------------------------------

while IFS= read -r link; do
  [[ -e "$SKILL_DIR/$link" ]] || fail "SKILL.md links to missing file: $link"
done < <(grep -oE '\]\((reference|kinds)/[^)#]+' "$SKILL" | sed -E 's/^\]\(//' | sort -u)

exit 0
