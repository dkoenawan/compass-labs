#!/usr/bin/env bash
# pstack_models_test.sh
# Tests skills/setup/scripts/pstack-models.sh and its template (ADR-011,
# #98): the shipped template is subscription-safe; `check` reports missing
# and unsafe settings; `install` writes the template, refuses to overwrite a
# different file without --force, and keeps a backup with it. Runs against a
# throwaway CLAUDE_CONFIG_DIR, never the real ~/.claude.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

SCRIPT="$REPO_ROOT/skills/setup/scripts/pstack-models.sh"
TEMPLATE="$REPO_ROOT/skills/setup/templates/pstack-models.md"
[[ -f "$SCRIPT" ]] || fail "pstack-models.sh not found"
[[ -f "$TEMPLATE" ]] || fail "template not found"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
export CLAUDE_CONFIG_DIR="$work/config"

run() { set +e; OUT="$(bash "$SCRIPT" "$@" 2>&1)"; CODE=$?; set -e 2>/dev/null || true; }

# 1. The shipped template is safe and carries pstack's markers.
run check "$TEMPLATE"
assert_eq 0 "$CODE" "the shipped template should pass check: $OUT"
content="$(cat "$TEMPLATE")"
assert_contains "$content" "# defaults: 3" "template should carry '# defaults: 3'"
assert_contains "$content" "# budget: medium (high)" "template should record the medium budget"
if grep -v '^#' "$TEMPLATE" | grep -Eqi 'fable|gemini|gpt|grok|claude-'; then
  fail "a template role names fable, another vendor or a raw Cursor slug"
fi

# 2. Missing settings: exit 1.
run check
assert_eq 1 "$CODE" "check with no settings file should exit 1"
assert_contains "$OUT" "missing:" "check should say the file is missing"

# 3. Install writes the template to the config dir's rules/.
run install
assert_eq 0 "$CODE" "install into an empty config dir should succeed: $OUT"
cmp -s "$TEMPLATE" "$CLAUDE_CONFIG_DIR/rules/pstack-models.md" || fail "installed file should equal the template"
run check
assert_eq 0 "$CODE" "check after install should pass"
run install
assert_eq 0 "$CODE" "re-installing an identical file should succeed"

# 4. Unsafe settings, e.g. after running pstack's own /setup-pstack.
unsafe="$CLAUDE_CONFIG_DIR/rules/pstack-models.md"
sed -i 's/^swarm workers: .*/swarm workers: fable high/' "$unsafe"
run check
assert_eq 2 "$CODE" "a fable role should be unsafe"
assert_contains "$OUT" "'fable'" "check should name the unsafe model"
sed -i 's/^swarm workers: .*/swarm workers: opus xhigh/' "$unsafe"
run check
assert_eq 2 "$CODE" "an xhigh effort should be unsafe"
sed -i 's/^swarm workers: .*/swarm workers: claude-opus-5-5-high, gemini-4-neon-xhigh/' "$unsafe"
run check
assert_eq 2 "$CODE" "raw Cursor slugs and gemini should be unsafe"
sed -i '/^hillclimb: /d' "$unsafe"
run check
assert_contains "$OUT" "role missing: 'hillclimb'" "a missing role should be reported"
sed -i 's/^swarm workers: .*/swarm workers: inherit-parent/' "$unsafe"
echo "hillclimb: auto" >> "$unsafe"
run check
assert_eq 0 "$CODE" "inherit-parent and auto should be safe: $OUT"

# 5. Install won't overwrite a different file without --force; with it, a backup stays.
echo "swarm workers: fable high" >> "$unsafe"
before="$(cat "$unsafe")"
run install
assert_eq 3 "$CODE" "install over a different file should refuse without --force"
assert_eq "$before" "$(cat "$unsafe")" "the refused install should leave the file alone"
run install --force
assert_eq 0 "$CODE" "install --force should succeed"
assert_contains "$OUT" "backup:" "install --force should report its backup"
backup="$(ls "$CLAUDE_CONFIG_DIR"/rules/pstack-models.md.bak.* 2>/dev/null | head -1)"
[[ -n "$backup" ]] || fail "a backup file should exist"
assert_eq "$before" "$(cat "$backup")" "the backup should hold the replaced settings"
cmp -s "$TEMPLATE" "$unsafe" || fail "install --force should write the template"

# 6. conflicts lists other pstack plugins (e.g. the community port).
mkdir -p "$CLAUDE_CONFIG_DIR/plugins"
echo '{"plugins":{"pstack@cursor-plugins":[],"pstack@pstack-claude":[],"trellis@trellis":[]}}' > "$CLAUDE_CONFIG_DIR/plugins/installed_plugins.json"
run conflicts
assert_eq "pstack@pstack-claude" "$OUT" "conflicts should list only the other pstack plugin"

echo "pstack_models_test: ok"
