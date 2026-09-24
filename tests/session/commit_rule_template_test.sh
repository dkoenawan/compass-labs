#!/usr/bin/env bash
# commit_rule_template_test.sh
# Validates the generalized rule template (D8, task 14) and that
# SKILL.md's one-time setup step now does the real copy instead of a
# TODO placeholder.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

TEMPLATE="$REPO_ROOT/skills/session/templates/rules/compass-sessions.md"
LIVE_RULE="$REPO_ROOT/.claude/rules/compass-sessions.md"
SKILL="$REPO_ROOT/skills/session/SKILL.md"

[[ -f "$TEMPLATE" ]] || fail "skills/session/templates/rules/compass-sessions.md not found"
[[ -f "$LIVE_RULE" ]] || fail ".claude/rules/compass-sessions.md not found (this repo's own live rule)"

template_content="$(cat "$TEMPLATE")"

# Generalized: no #22-specific text.
assert_not_contains "$template_content" "#22" \
  "the template rule should be generalized, not reference issue #22"
assert_not_contains "$template_content" "2026-08-19-session-lifecycle" \
  "the template rule should not hard-code this session's own slug"

# Still carries the substantive rules.
assert_contains "$template_content" "decision" "template rule should mention decision entries"
assert_contains "$template_content" "milestone" "template rule should mention milestone entries"
assert_contains "$template_content" "paths:" "template rule should keep the paths: frontmatter scoping it to docs/sessions/**"

skill_content="$(cat "$SKILL")"
assert_not_contains "$skill_content" "TODO (task 14)" \
  "SKILL.md's one-time setup TODO should be replaced by the real copy step"
assert_contains "$skill_content" "compass-sessions.md" \
  "SKILL.md's one-time setup should reference the rule template/destination"
assert_contains "$skill_content" "session-commit-guard.sh" \
  "SKILL.md should reference the commit guard hook"

echo "ok: commit rule template validated"
exit 0
