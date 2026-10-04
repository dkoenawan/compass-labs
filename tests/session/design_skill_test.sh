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

# --- Kind catalogue and contract (DES-003, REQ-002, REQ-003) -----------------

assert_contains "$content" "## Kind catalogue" "SKILL.md should have the kind catalogue"
assert_contains "$content" "### What a kind supplies" "SKILL.md should have the kind contract"
for ref in 46 47 48 49 50 51; do
  assert_contains "$content" "dkoenawan/compass-labs#$ref" "kind catalogue should cite dkoenawan/compass-labs#$ref"
done
# Follow-up issues must be fully qualified so they resolve in a consuming repo.
if grep -nE '(^|[^/a-z0-9-])#(4[6-9]|5[01])\b' "$SKILL" | grep -q .; then
  fail "SKILL.md should cite follow-up issues as dkoenawan/compass-labs#nn"
fi

# --- Significant choices and principles check (DES-006) ---------------------

assert_contains "$content" "## Significant choices and principles check" "SKILL.md should have the choices and principles section"
assert_contains "$content" "At least two options" "a significant choice should need at least two options"
assert_contains "$content" "user chose" "the user should choose significant options"
for principle in KISS YAGNI SOLID "single responsibility" "open/closed" "Liskov substitution" \
  "interface segregation" "dependency inversion"; do
  assert_contains "$content" "$principle" "principles check should name '$principle'"
done
for mark in "*met*" "*traded off*" "*n/a*"; do
  assert_contains "$content" "$mark" "principles check should define the mark $mark"
done
assert_contains "$content" "Rejected under YAGNI" "SKILL.md should have the Rejected under YAGNI list"
assert_contains "$content" "docs/registry/decisions/" "SKILL.md should say how ADRs are handled"

# --- Design -> Implement handoff (DES-012) ----------------------------------

assert_contains "$content" "## Design → Implement handoff" "SKILL.md should have the handoff contract"
for col in ID Component Covers Result Check; do
  assert_contains "$content" "| $col |" "handoff contract should define the column '$col'"
done
assert_contains "$content" "Coverage self-check" "SKILL.md should have the coverage self-check"

# --- Claude Design handoff (DES-013, REQ-033) -------------------------------

assert_contains "$content" "## Claude Design handoff" "SKILL.md should have the Claude Design handoff"
assert_contains "$content" "design/ui-handoff.md" "the handoff should name design/ui-handoff.md"
assert_contains "$content" "assets/ui-design.zip" "the returned design should keep the zip at assets/ui-design.zip"
assert_contains "$content" "assets/ui-{screen}.png" "the returned design should embed one PNG per screen"
assert_contains "$content" "Never unzip it into the repo" "the zip should never be unzipped into the repo"
assert_contains "$content" "Never specify visual values" "the handoff should forbid visual values"

# --- On-demand files exist -------------------------------------------------

while IFS= read -r link; do
  [[ -e "$SKILL_DIR/$link" ]] || fail "SKILL.md links to missing file: $link"
done < <(grep -oE '\]\((reference|kinds)/[^)#]+' "$SKILL" | sed -E 's/^\]\(//' | sort -u)

exit 0
