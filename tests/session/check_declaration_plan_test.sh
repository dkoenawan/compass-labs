#!/usr/bin/env bash
# check_declaration_plan_test.sh
# Component tests for check-declaration.sh --plan (#30 DES-002, REQ-006,
# REQ-012, REQ-013, REQ-025), on the deploy fixtures: steps in declared
# order, production-affecting steps never "may run", every step after a
# waiting one waits, own_session waits for a release session, and the
# proposed tier matches the Deploy standard's tier table. No repo command
# runs.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

SCRIPT="$REPO_ROOT/skills/deploy/scripts/check-declaration.sh"
FIX="$REPO_ROOT/tests/fixtures/deploy"
SERVICE="$FIX/fixture-service/.claude/deploy.json"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# plan_for <declaration-json-file>: runs --plan on a temp repo holding it.
# Sets OUT and STATUS. The repo has the fixture's files, so versioning passes.
plan_for() {
  local dir="$work/repo-$RANDOM$RANDOM"
  cp -R "$FIX/fixture-service" "$dir"
  cp "$1" "$dir/.claude/deploy.json"
  OUT="$(cd "$work" && bash "$SCRIPT" "$dir" --plan 2>&1)"
  STATUS=$?
  PLAN_DIR="$dir"
}
step_line() { grep -F "$1" <<<"$OUT" | head -1; }

assert_no_prod_may_run() {
  local line
  while IFS= read -r line; do
    [[ "$line" == *"production_affecting"* && "$line" == *"may run"* ]] \
      && fail "a production-affecting step should never be 'may run': $line"
  done <<<"$OUT"
  return 0
}

# 1. fixture-service: staging may run, production waits, merge waits; full.
plan_for "$SERVICE"
assert_eq 0 "$STATUS" "--plan on fixture-service should exit 0 ($OUT)"
assert_contains "$OUT" "plan: release mode: in_session"
assert_contains "$(step_line "'deploy to staging'")" "may run: ./deploy.sh staging" "staging should be allowed, word for word"
assert_contains "$(step_line "'deploy to production'")" "waits for the user's instruction" "production should wait"
assert_contains "$(step_line "'merge the pull request'")" "waits for the user" "the merge should wait"
assert_contains "$(step_line "L1 part 'web-service'")" "may run, if L1 is needed" "routine L1 setup should be allowed if L1 is needed"
assert_no_prod_may_run
assert_contains "$OUT" "plan: tier: full: a production-affecting step is waiting: deploy to production"
# Declared order: L1 before L2, and L2 in order.
order="$(grep -oE "L1 part|L2 step [0-9]+" <<<"$OUT" | tr '\n' ' ')"
assert_eq "L1 part L2 step 1 L2 step 2 L2 step 3 " "$order" "steps should print in declared order, L1 first"

# 2. Once a step waits, every later one waits, even a routine one.
jq '.l2.steps = [.l2.steps[1], .l2.steps[0], .l2.steps[2]]' "$SERVICE" >"$work/swapped.json"
plan_for "$work/swapped.json"
assert_contains "$(step_line "'deploy to staging'")" "waits (an earlier step waits for the user)" \
  "a routine step after a waiting one should wait"
assert_no_prod_may_run

# 3. own_session: no L2 step runs; skip, or short if L1 runs.
plan_for "$FIX/fixture-service/variants/own-session.json"
assert_eq 0 "$STATUS"
[[ "$(grep -c "^plan: L2 step .*waits for a release session" <<<"$OUT")" == 3 ]] \
  || fail "every L2 step should wait for a release session ($OUT)"
grep -E "^plan: L2 step .*may run" <<<"$OUT" && fail "no L2 step should run with own_session"
assert_contains "$OUT" "plan: tier: skip: the release waits for a release session"
assert_contains "$OUT" "plan: tier if L1 runs: short"

# 4. A compass-labs-like release: routine steps and a merge only -> short.
jq '.l2.steps = [
      {"name":"bump the version","run":"echo bump {level}","kind":"routine"},
      {"name":"push the session branch","run":"echo push {branch}","kind":"routine"},
      {"name":"merge the pull request","merge":true,"kind":"production_affecting"}]' \
  "$SERVICE" >"$work/routine.json"
plan_for "$work/routine.json"
assert_contains "$OUT" "plan: tier: short: every step that runs is routine (standard change); the merge doesn't count" \
  "a routine release with a merge should propose short"
assert_contains "$(step_line "'bump the version'")" "may run: echo bump {level}" "placeholders should print as declared"

# 5. A production-affecting L1 step: full if L1 runs, and L2 waits behind it.
jq '.l1.parts[0].setup[0].kind = "production_affecting"' "$work/routine.json" >"$work/l1prod.json"
plan_for "$work/l1prod.json"
assert_contains "$(step_line "L1 part 'web-service'")" "waits for the user" "a production-affecting L1 step should wait"
assert_contains "$OUT" "plan: tier if L1 runs: full" "a production-affecting L1 step should make L1 full"
assert_contains "$OUT" "no L2 step runs until the user instructs it"
assert_no_prod_may_run

# 6. fixture-docs-only: skip, nothing runs.
OUT="$(bash "$SCRIPT" "$FIX/fixture-docs-only" --plan 2>&1)"
STATUS=$?
assert_eq 3 "$STATUS" "--plan on none should exit 3"
assert_contains "$OUT" "plan: tier: skip: nothing to deploy, per the declaration"

# 7. fixture-new-part: plans like fixture-service (the offer is Deploy's).
OUT="$(bash "$SCRIPT" "$FIX/fixture-new-part" --plan 2>&1)"
assert_contains "$OUT" "plan: L1 part 'web-service'" "fixture-new-part plans its declared part"
assert_not_contains "$OUT" "billing-service" "the plan only reads the declaration, never the design"

# 8. Nothing from the repo runs with --plan.
jq '.l2.steps[0].run = "touch RAN-L2" | .l1.parts[0].setup[0].run = "touch RAN-L1" | .confirmation.run = "touch RAN-CHECK"' \
  "$SERVICE" >"$work/markers.json"
plan_for "$work/markers.json"
assert_eq 0 "$STATUS"
for m in RAN-L1 RAN-L2 RAN-CHECK deploy-log; do
  [[ ! -e "$PLAN_DIR/$m" && ! -e "$work/$m" ]] || fail "--plan should run nothing ($m exists)"
done

# 9. The tiers used are exactly the standard's three.
tiers="$(grep -oE "^\| \*\*(skip|short|full)\*\*" "$REPO_ROOT/skills/deploy/SKILL.md" | tr -d '|* ' | sort | tr '\n' ' ')"
assert_eq "full short skip " "$tiers" "the standard's tier table should name skip, short and full"

echo "ok: check-declaration.sh --plan checked"
exit 0
