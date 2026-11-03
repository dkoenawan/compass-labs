#!/usr/bin/env bash
# check_declaration_test.sh
# Component tests for skills/deploy/scripts/check-declaration.sh's
# validation (#30 DES-002, REQ-003, REQ-004, REQ-013), on the deploy
# fixtures (tests/fixtures/deploy/): no declaration, a missing item named,
# a merge marked routine, none, valid, the versioning checks, bad JSON, no
# jq (fails open with its own exit code), and no repo command ever runs.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

SCRIPT="$REPO_ROOT/skills/deploy/scripts/check-declaration.sh"
FIX="$REPO_ROOT/tests/fixtures/deploy"
[[ -x "$SCRIPT" ]] || fail "check-declaration.sh not found or not executable"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# copy_fixture <name>: a temp copy of a fixture; prints its path.
copy_fixture() {
  local dest="$work/$1-$RANDOM$RANDOM"
  cp -R "$FIX/$1" "$dest"
  echo "$dest"
}

# run_check <args...>: sets OUT and STATUS.
run_check() {
  OUT="$(bash "$SCRIPT" "$@" 2>&1)"
  STATUS=$?
}

# A declared run that would leave a marker if anything ran it.
plant_markers() {
  local decl="$1/.claude/deploy.json"
  jq '.l2.steps[0].run = "touch RAN-L2" | .l1.parts[0].setup[0].run = "touch RAN-L1" | .confirmation.run = "touch RAN-CHECK"' \
    "$decl" >"$decl.tmp" && mv "$decl.tmp" "$decl"
}
assert_nothing_ran() {
  local dir="$1"
  for m in RAN-L1 RAN-L2 RAN-CHECK deploy-log; do
    [[ ! -e "$dir/$m" ]] || fail "no repo command should run, but $m exists in ${dir#"$work"/}"
  done
}

# 1. fixture-no-declaration: no declaration, and how to declare one.
d="$(copy_fixture fixture-no-declaration)"
run_check "$d"
assert_eq 2 "$STATUS" "a repo with no declaration should exit 2"
assert_contains "$OUT" "no declaration" "the result should say there is no declaration"
assert_contains "$OUT" "skills/deploy/SKILL.md (section 2, The deploy declaration)" "it should name where the standard describes it"
assert_contains "$OUT" "reference/declaration.md" "it should name the declaration reference"
assert_nothing_ran "$d"

# 2. fixture-service is valid.
d="$(copy_fixture fixture-service)"
run_check "$d"
assert_eq 0 "$STATUS" "fixture-service should be valid ($OUT)"
assert_contains "$OUT" "check-declaration: valid"

# 3. A fixture-service copy with no rollback names "rollback".
cp "$FIX/fixture-service/variants/no-rollback.json" "$d/.claude/deploy.json"
run_check "$d"
assert_eq 1 "$STATUS" "a declaration with no rollback should be invalid"
assert_contains "$OUT" "missing: rollback" "the missing rollback should be named"
assert_nothing_ran "$d"

# 4. Each of REQ-001's other items is named when it's left out.
for pair in "del(.release_mode)|release mode" "del(.l1)|L1 setup" "del(.l2.steps)|L2 steps" \
  "del(.confirmation)|confirmation" "del(.l2.steps[0].kind)|kind" "del(.deployment)|deployment"; do
  filter="${pair%%|*}" name="${pair#*|}"
  jq "$filter" "$FIX/fixture-service/.claude/deploy.json" >"$d/.claude/deploy.json"
  run_check "$d"
  assert_eq 1 "$STATUS" "'$filter' should make the declaration invalid"
  assert_contains "$OUT" "missing: $name" "'$filter' should name '$name' as missing"
done

# 5. A merge marked routine is named.
jq '.l2.steps[2].kind = "routine"' "$FIX/fixture-service/.claude/deploy.json" >"$d/.claude/deploy.json"
run_check "$d"
assert_eq 1 "$STATUS" "a routine merge should be invalid"
assert_contains "$OUT" "merge marked routine" "a routine merge should be named"
assert_contains "$OUT" "'merge the pull request'" "the merge step should be named"

# 6. Versioning: a tag form without {version}, and a missing version file.
jq '.versioning.tag = "release-latest"' "$FIX/fixture-service/.claude/deploy.json" >"$d/.claude/deploy.json"
run_check "$d"
assert_eq 1 "$STATUS" "a tag form without {version} should be invalid"
assert_contains "$OUT" "versioning.tag has no {version}: release-latest"
jq '.versioning.file = "VERSION"' "$FIX/fixture-service/.claude/deploy.json" >"$d/.claude/deploy.json"
run_check "$d"
assert_eq 1 "$STATUS" "a missing version file should be invalid"
assert_contains "$OUT" "versioning.file not found: VERSION"

# 7. fixture-docs-only: none.
d="$(copy_fixture fixture-docs-only)"
run_check "$d"
assert_eq 3 "$STATUS" "deployment none should exit 3"
assert_contains "$OUT" "nothing to deploy, per the declaration"

# 8. fixture-new-part's declaration is valid (the uncovered part is Deploy's call).
run_check "$FIX/fixture-new-part"
assert_eq 0 "$STATUS" "fixture-new-part should be valid"

# 9. Bad JSON.
d="$(copy_fixture fixture-service)"
echo '{ "deployment": ' >"$d/.claude/deploy.json"
run_check "$d"
assert_eq 1 "$STATUS" "bad JSON should be invalid"
assert_contains "$OUT" "invalid"

# 10. No repo command runs, even on a valid declaration with markers planted.
d="$(copy_fixture fixture-service)"
plant_markers "$d"
run_check "$d"
assert_eq 0 "$STATUS" "the planted declaration should still be valid"
assert_nothing_ran "$d"

# 11. No jq: warns, checks nothing, and exits 4 (fails open).
nojq="$work/nojq"
make_path_without_jq "$nojq"
OUT="$(PATH="$nojq" bash "$SCRIPT" "$FIX/fixture-service" 2>&1)"
STATUS=$?
assert_eq 4 "$STATUS" "with no jq the script should exit 4"
assert_contains "$OUT" "jq not found" "with no jq the script should warn"

echo "ok: check-declaration.sh validation checked"
exit 0
