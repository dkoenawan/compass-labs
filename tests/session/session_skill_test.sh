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

echo "ok: session skill orchestration rules validated"
exit 0
