#!/usr/bin/env bash
# requirements_verification_skills_test.sh
# Sanity-checks the thin requirements/verification skills (D1c, D1) and
# that define/test now preload them (task 10).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

REQ_SKILL="$REPO_ROOT/skills/requirements/SKILL.md"
VER_SKILL="$REPO_ROOT/skills/verification/SKILL.md"
DEFINE_AGENT="$REPO_ROOT/agents/define.md"
TEST_AGENT="$REPO_ROOT/agents/test.md"

[[ -f "$REQ_SKILL" ]] || fail "skills/requirements/SKILL.md not found"
[[ -f "$VER_SKILL" ]] || fail "skills/verification/SKILL.md not found"

req_content="$(cat "$REQ_SKILL")"
assert_contains "$req_content" $'name: requirements\n' "requirements skill should declare name: requirements"
assert_contains "$req_content" "EARS" "requirements skill should cover EARS syntax"
assert_contains "$req_content" "Given/When/Then" "requirements skill should cover acceptance criteria"
assert_contains "$req_content" "29148" "requirements skill should reference the ISO/IEC/IEEE 29148 checklist"

ver_content="$(cat "$VER_SKILL")"
assert_contains "$ver_content" $'name: verification\n' "verification skill should declare name: verification"
assert_contains "$ver_content" "| ID | Covers REQ | Method | Result | Evidence |" \
  "verification skill should spell out the exact column order check-traceability.sh depends on"
assert_contains "$ver_content" "check-traceability.sh" \
  "verification skill should call out the traceability gate by name"

define_content="$(cat "$DEFINE_AGENT")"
assert_contains "$define_content" "compass-labs:requirements" \
  "agents/define.md should preload compass-labs:requirements"

test_content="$(cat "$TEST_AGENT")"
assert_contains "$test_content" "compass-labs:verification" \
  "agents/test.md should preload compass-labs:verification"

echo "ok: requirements/verification skills validated"
exit 0
