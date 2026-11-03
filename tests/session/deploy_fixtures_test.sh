#!/usr/bin/env bash
# deploy_fixtures_test.sh
# The deploy fixtures (#30 DES-013) are usable as Test needs them, with no
# change to the fixture: each has what its criteria name, check-health.sh
# switches between healthy and unhealthy in a copy, deploy.sh stays inside
# the copy, and fixture-new-part's design adds billing-service, which its
# declaration doesn't cover.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

FIX="$REPO_ROOT/tests/fixtures/deploy"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

for fx in fixture-service fixture-no-declaration fixture-new-part fixture-docs-only; do
  [[ -d "$FIX/$fx" ]] || fail "$fx not found"
done
[[ -e "$FIX/fixture-no-declaration/.claude/deploy.json" ]] && fail "fixture-no-declaration should have no declaration"
assert_eq "none" "$(jq -r .deployment "$FIX/fixture-docs-only/.claude/deploy.json")" "fixture-docs-only should declare none"
for v in no-rollback own-session; do
  jq -e . "$FIX/fixture-service/variants/$v.json" >/dev/null || fail "variants/$v.json should be valid JSON"
done
assert_eq "null" "$(jq -r '.rollback' "$FIX/fixture-service/variants/no-rollback.json")" "the no-rollback variant should have no rollback"
assert_eq "own_session" "$(jq -r '.release_mode' "$FIX/fixture-service/variants/own-session.json")"

# check-health.sh switches, in a copy.
for fx in fixture-service fixture-no-declaration fixture-new-part; do
  d="$work/$fx"
  cp -R "$FIX/$fx" "$d"
  out="$(cd "$d" && ./check-health.sh)"; status=$?
  assert_eq 0 "$status" "$fx: check-health.sh should pass by default"
  assert_eq "healthy" "$out"
  echo unhealthy >"$d/health-state"
  out="$(cd "$d" && ./check-health.sh)"; status=$?
  assert_eq 1 "$status" "$fx: check-health.sh should fail when unhealthy"
  assert_eq "unhealthy" "$out"
  out="$(cd "$d" && ./deploy.sh staging)"
  assert_eq "deployed staging" "$out"
  assert_eq "deployed staging" "$(cat "$d/deploy-log")" "deploy.sh should log inside the copy"
  [[ ! -e "$FIX/$fx/deploy-log" ]] || fail "the fixture itself should be unchanged"
done

# fixture-new-part: billing-service is new in the design and not declared.
delta="$(cat "$FIX/fixture-new-part/docs/sessions/2026-01-01-billing/design/index.md")"
assert_contains "$delta" '| `billing-service` (C4 container) | new |' "the design should add billing-service"
jq -e '[.l1.parts[].name] | index("billing-service") == null' "$FIX/fixture-new-part/.claude/deploy.json" >/dev/null \
  || fail "fixture-new-part's declaration should not cover billing-service"
assert_contains "$(cat "$FIX/fixture-service/docs/sessions/2026-01-01-page-text/design/index.md")" "Wording only" \
  "fixture-service's design should change only page text"

echo "ok: deploy fixtures checked"
exit 0
