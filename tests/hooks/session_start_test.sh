#!/usr/bin/env bash
# session_start_test.sh
# hooks/session-start.sh (ADR-011, #98): silent when pstack's model settings
# are safe; one warning line, in any session, when they are missing or
# unsafe or a second pstack plugin is installed; always exits 0. Uses a
# throwaway CLAUDE_CONFIG_DIR, never the real ~/.claude.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

HOOK="$REPO_ROOT/hooks/session-start.sh"
TEMPLATE="$REPO_ROOT/skills/setup/templates/pstack-models.md"
cfg="$(mktemp -d)"
trap 'rm -rf "$cfg"' EXIT
export CLAUDE_CONFIG_DIR="$cfg"
mkdir -p "$cfg/rules"
input='{"cwd":"/tmp","agent_type":""}'

cp "$TEMPLATE" "$cfg/rules/pstack-models.md"
run_hook "$HOOK" "$input"
assert_eq "0" "$HOOK_EXIT" "hook should exit 0"
assert_eq "" "$HOOK_STDOUT" "safe settings should print nothing"

rm "$cfg/rules/pstack-models.md"
run_hook "$HOOK" "$input"
assert_eq "0" "$HOOK_EXIT" "missing settings should still exit 0"
assert_contains "$HOOK_STDOUT" "/trellis:setup" "missing settings should point at setup"
assert_contains "$HOOK_STDOUT" "missing:" "the warning should give the reason"

sed 's/^swarm workers: .*/swarm workers: fable high/' "$TEMPLATE" > "$cfg/rules/pstack-models.md"
run_hook "$HOOK" "$input"
assert_contains "$HOOK_STDOUT" "unsafe:" "an unsafe role should be warned about"

cp "$TEMPLATE" "$cfg/rules/pstack-models.md"
mkdir -p "$cfg/plugins"
echo '{"plugins":{"pstack@cursor-plugins":[],"pstack@pstack-claude":[]}}' > "$cfg/plugins/installed_plugins.json"
run_hook "$HOOK" "$input"
assert_contains "$HOOK_STDOUT" "pstack@pstack-claude" "a second pstack plugin should be named"

echo "ok: session-start.sh validated"
