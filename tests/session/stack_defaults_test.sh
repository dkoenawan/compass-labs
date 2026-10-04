#!/usr/bin/env bash
# stack_defaults_test.sh
# REQ-010 (#27 DES-007): the stack defaults are stated once, in
# skills/design/reference/stack-defaults.md. Every other file in skills/,
# agents/ and README.md that states a default stack links to it, and none
# names a different default for the same stack area.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

SOURCE_REL="skills/design/reference/stack-defaults.md"
SOURCE="$REPO_ROOT/$SOURCE_REL"
[[ -f "$SOURCE" ]] || fail "$SOURCE_REL not found"

src="$(cat "$SOURCE")"
for default in "React + TypeScript" "Node.js" "CQRS" "Scalar" "PostgreSQL through Prisma" "Terraform"; do
  assert_contains "$src" "$default" "stack-defaults.md should state the default '$default'"
done
assert_contains "$src" "established stack always wins" "stack-defaults.md should say an established stack wins"

cd "$REPO_ROOT" || fail "cannot cd to repo root"

# 1. Every file that states a default stack is the source or links to it.
mapfile -t stating < <(grep -rliE 'default (tech )?stack|stack defaults?|default:? *(React|Node|Postgres|Prisma|Terraform)' \
  skills agents README.md | sort)
for file in "${stating[@]}"; do
  [[ "$file" == "$SOURCE_REL" ]] && continue
  grep -q 'stack-defaults.md' "$file" \
    || fail "$file states a default stack but doesn't link to $SOURCE_REL"
done

# 2. No file names a different default for a stack area.
conflict_re='default[^.|]{0,15}\b(Pulumi|CloudFormation|CDK|Ansible|Bicep|Swagger|MySQL|MongoDB|SQLite|Vue|Angular|Svelte|Django|FastAPI|Flask|Express)\b'
if hits="$(grep -rniE "$conflict_re" skills agents README.md)"; then
  echo "$hits" >&2
  fail "a file names a default that conflicts with $SOURCE_REL"
fi

# 3. The callers named in the design link to the source.
for file in skills/init/SKILL.md skills/bootstrap-new-project/SKILL.md README.md; do
  grep -q 'stack-defaults.md' "$file" || fail "$file should link to $SOURCE_REL"
done

exit 0
