#!/usr/bin/env bash
# session_skill_test.sh
# Static checks on skills/session/SKILL.md's orchestration rules that live
# tests found missing (Test phase fix pass). These are prose rules for the
# model, so this only checks the rule is stated — whether the model follows
# it is re-checked live (verification.md).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

skill="$(cat "$REPO_ROOT/skills/session/SKILL.md")"

# VER-013: the milestone commit must stage the phase's artifact explicitly,
# not just log.md.
assert_contains "$skill" 'git add docs/sessions/{slug}/{artifact} docs/sessions/{slug}/log.md' \
  "milestone gate step d should stage the phase artifact together with log.md"
assert_contains "$skill" "git status --porcelain" \
  "milestone gate should state the clean-tree precondition"
assert_contains "$skill" 'files_changed`** (the fold-back edits' \
  "Close step 2 should stage the Close agent's fold-back docs so archive-session.sh sees a clean tree"

# VER-010: handoff entry for every phase-agent start, Key decisions mirror,
# phase agents' milestone entries downgraded.
assert_contains "$skill" "Handoff — logged every time, before the agent starts" \
  "main loop step 1 should require a handoff entry for every phase-agent start"
assert_contains "$skill" "Key decisions mirror (REQ-007)" \
  "main loop should require mirroring decisions/milestones into Key decisions"
assert_contains "$skill" "A phase agent's \`milestone\` entry is never appended as a milestone" \
  "main loop should downgrade phase agents' milestone entries"

contract="$(cat "$REPO_ROOT/skills/session/reference/phase-agent-contract.md")"
assert_contains "$contract" "Never emit a \`milestone\` log entry" \
  "phase-agent contract should forbid phase agents from emitting milestone entries"
assert_not_contains "$contract" "handoff | decision | attempt | milestone | note" \
  "phase-agent contract should no longer list milestone as an event type agents may return"

# #27 DES-011: the Design gate shows the context view and delta list
# (REQ-016) and runs check-design.sh before the milestone (REQ-017).
assert_contains "$skill" "design/index.md#context-view" "the Design gate should show the context view"
assert_contains "$skill" "design/index.md#delta-list" "the Design gate should show the delta list"
assert_contains "$skill" "a4. **Design milestone only**" "milestone gate should have step a4 for Design"
assert_contains "$skill" "scripts/check-design.sh {session-dir}" "step a4 should run check-design.sh"

# #28 DES-005: the Implement gate shows statuses and variations above the
# options, decides each variation, logs one decision and holds approval
# while rework is outstanding (REQ-004, REQ-005).
assert_contains "$skill" "**Implement gate** (REQ-004, REQ-005)" "milestone gate should have an Implement gate"
assert_contains "$skill" "implement/as-built.md" "the Implement gate should read implement/as-built.md"
assert_contains "$skill" "**accept as built**, or **send back for rework**" \
  "the Implement gate should ask accept or rework for each variation"
assert_contains "$skill" "Append one \`decision\` entry naming every variation's outcome" \
  "the Implement gate should log one decision naming every outcome"
assert_contains "$skill" "Don't approve the Implement milestone while any rework is outstanding" \
  "the Implement gate should hold approval while rework is outstanding"
gate="$(awk '/\*\*Implement gate\*\*/,/A past session with a root `tasks.md` is shown as before/' "$REPO_ROOT/skills/session/SKILL.md")"
[[ -n "$gate" ]] || fail "could not extract the Implement gate"
order_ok="$(awk '/every variation from the Variations table/{a=NR} /accept as built/{b=NR} /naming every variation.s outcome/{c=NR} /Relay any rework/{d=NR} /Don.t approve the Implement milestone/{e=NR} END{print (a && a<b && b<c && c<d && d<e) ? "yes" : "no"}' <<<"$gate")"
assert_eq "yes" "$order_ok" "the Implement gate's steps should be in order"

echo "ok: session skill orchestration rules validated"
exit 0
