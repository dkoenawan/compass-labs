#!/usr/bin/env bash
# docs_test.sh
# Sanity-checks that the session lifecycle is actually documented (task
# 13, REQ-015): README's three entry points and CLAUDE.md's directory
# rules both mention it.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

readme="$(cat "$REPO_ROOT/README.md")"
claude_md="$(cat "$REPO_ROOT/CLAUDE.md")"

assert_contains "$readme" "/compass-labs:session" "README should document /compass-labs:session"

# The plugin is named compass-labs, so /compass:session does not exist
# (VER-020). No session-facing file may document it.
for f in README.md skills/session/SKILL.md hooks/session-start.sh agents/orchestrator.md; do
  assert_not_contains "$(cat "$REPO_ROOT/$f")" "/compass:session" \
    "$f documents /compass:session, which does not exist (use /compass-labs:session)"
done
assert_contains "$readme" "compass-labs:orchestrator" "README should document the --agent entry point"
assert_contains "$readme" '"agent": "compass-labs:orchestrator"' \
  "README should show the repo-default settings.json snippet"

assert_contains "$claude_md" "agents/" "CLAUDE.md directory rules should mention agents/"
assert_contains "$claude_md" "tests/" "CLAUDE.md directory rules should mention tests/"
assert_contains "$claude_md" '`plugin.json` goes inside `.claude-plugin/`' \
  "CLAUDE.md should still say .claude-plugin/ holds only plugin.json"

echo "ok: session lifecycle docs validated"
exit 0
