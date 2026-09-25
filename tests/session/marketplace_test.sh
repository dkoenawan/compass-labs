#!/usr/bin/env bash
# marketplace_test.sh
# The marketplace entry lists skills explicitly (`strict: true`), so a skill
# missing from that list may not ship with a marketplace install even though
# `claude --plugin-dir` (which ignores the list) loads it. Checks that the
# session lifecycle's skills are listed and have a SKILL.md.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

MARKETPLACE="$REPO_ROOT/.claude-plugin/marketplace.json"
[[ -f "$MARKETPLACE" ]] || fail ".claude-plugin/marketplace.json not found"

listed="$(jq -r '.plugins[] | select(.name=="compass-labs") | .skills[]' "$MARKETPLACE")" \
  || fail "marketplace.json is not valid JSON"

for skill in session requirements verification; do
  assert_contains "$listed" "./skills/$skill" \
    "marketplace.json should list ./skills/$skill"
  [[ -f "$REPO_ROOT/skills/$skill/SKILL.md" ]] || fail "skills/$skill/SKILL.md not found"
done

exit 0
