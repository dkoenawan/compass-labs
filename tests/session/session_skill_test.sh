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

echo "ok: session skill orchestration rules validated"
exit 0
