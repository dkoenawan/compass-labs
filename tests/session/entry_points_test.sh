#!/usr/bin/env bash
# entry_points_test.sh
# Sanity-checks the static entry points (D3, REQ-015): the orchestrator
# agent exists with the expected frontmatter shape, and the session skill
# is the /compass-labs:session slash command itself — no commands/*.md
# may share a name with a skills/*/ directory, because a command shadows
# the same-named skill for the Skill tool and `skills:` preload (VER-021).
# Does not invoke the CLI (that verification is live — see verification.md).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

AGENT_FILE="$REPO_ROOT/agents/orchestrator.md"
SKILL_FILE="$REPO_ROOT/skills/session/SKILL.md"

[[ -f "$AGENT_FILE" ]] || fail "agents/orchestrator.md not found"
[[ -f "$SKILL_FILE" ]] || fail "skills/session/SKILL.md not found"

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

# No command may collide with a skill name (both resolve to compass-labs:<name>).
for cmd in "$REPO_ROOT"/commands/*.md; do
  [[ -f "$cmd" ]] || continue
  name="$(basename "$cmd" .md)"
  [[ ! -d "$REPO_ROOT/skills/$name" ]] || \
    fail "commands/$name.md collides with skills/$name/ (both resolve to compass-labs:$name; the command shadows the skill)"
done

skill_content="$(cat "$SKILL_FILE")"
assert_contains "$skill_content" '$ARGUMENTS' \
  "skills/session/SKILL.md should read its slash-command arguments via \$ARGUMENTS"
assert_not_contains "$skill_content" "user-invocable: false" \
  "skills/session/SKILL.md must stay user-invocable (it is the /compass-labs:session command)"

echo "ok: entry points validated"
exit 0
