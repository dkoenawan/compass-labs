#!/usr/bin/env bash
# entry_points_test.sh
# Sanity-checks the two static entry points (D3, REQ-015): the
# orchestrator agent and the /compass:session command exist with the
# expected frontmatter shape. Does not invoke the CLI (that verification
# is manual/one-off — see tasks.md).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

AGENT_FILE="$REPO_ROOT/agents/orchestrator.md"
COMMAND_FILE="$REPO_ROOT/commands/session.md"

[[ -f "$AGENT_FILE" ]] || fail "agents/orchestrator.md not found"
[[ -f "$COMMAND_FILE" ]] || fail "commands/session.md not found"

agent_content="$(cat "$AGENT_FILE")"

# `name:` must be the bare "orchestrator" — agent names can't contain ':'
# (that's reserved for plugin-scoped invocation, e.g. compass-labs:orchestrator).
assert_contains "$agent_content" $'name: orchestrator\n' \
  "agents/orchestrator.md should declare name: orchestrator"

assert_contains "$agent_content" "skills:" \
  "agents/orchestrator.md should preload the session skill via skills:"
assert_contains "$agent_content" "session" \
  "agents/orchestrator.md's skills: list should reference the session skill"

assert_contains "$agent_content" "Agent" \
  "agents/orchestrator.md should grant the Agent tool (it hands off to phase agents)"

command_content="$(cat "$COMMAND_FILE")"
assert_contains "$command_content" "session" \
  "commands/session.md should reference the session skill"

echo "ok: entry points validated"
exit 0
