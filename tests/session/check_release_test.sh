#!/usr/bin/env bash
# check_release_test.sh
# Component tests for skills/session/scripts/check-release.sh (#30
# DES-006, REQ-015): a full-tier record with no rollback prints "rollback
# missing" and exits 1; every tier passes when complete; each tier's
# required sections match the Deploy standard's tier table; an old-layout
# record passes with no check; the release template, filled in, passes.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

SCRIPT="$REPO_ROOT/skills/session/scripts/check-release.sh"
STD="$REPO_ROOT/skills/deploy/SKILL.md"
[[ -x "$SCRIPT" ]] || fail "check-release.sh not found or not executable"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

SECTIONS=("Lifecycles run and why" "Release strategy" "Completeness" "Steps run" "Confirmation" "Rollback" "Change record")

# write_record <dir> <tier> <section to leave out, or "">
write_record() {
  local dir="$1" tier="$2" skip="$3" s
  mkdir -p "$dir"
  {
    echo "# Release: test"
    echo
    echo "> Phase: Deploy | Started: 2026-01-01 | Status: Draft"
    echo "> Deploy tier: $tier: test reason"
    for s in "${SECTIONS[@]}"; do
      [[ "$s" == "$skip" ]] && continue
      printf '\n## %s\n\nbody\n' "$s"
    done
  } >"$dir/release.md"
}
run_check() { OUT="$(bash "$SCRIPT" "$1" 2>&1)"; STATUS=$?; }

# 1. Full tier with no rollback: refused, named.
write_record "$work/full-no-rollback" full "Rollback"
run_check "$work/full-no-rollback"
assert_eq 1 "$STATUS" "a full record with no rollback should be refused"
assert_contains "$OUT" "rollback missing" "the missing rollback should be named"

# 2. Every tier passes when complete.
for tier in skip short full; do
  write_record "$work/complete-$tier" "$tier" ""
  run_check "$work/complete-$tier"
  assert_eq 0 "$STATUS" "a complete $tier record should pass ($OUT)"
done

# 3. Each tier's required sections are the tier table's: leaving out a
# required one is refused, a not-required one passes.
for tier in skip short full; do
  col=$(( $(printf '%s\n' skip short full | grep -n "^$tier$" | cut -d: -f1) + 2 ))
  for s in "${SECTIONS[@]}"; do
    cell="$(grep -E "^\| $s \| " "$STD" | head -1 | awk -F'|' -v c="$col" '{gsub(/^ +| +$/,"",$c); print $c}')"
    write_record "$work/$tier-$RANDOM" "$tier" "$s"
    dir="$(ls -td "$work/$tier-"* | head -1)"
    run_check "$dir"
    if [[ "$cell" == "not required"* ]]; then
      assert_eq 0 "$STATUS" "$tier without '$s' should pass (the table says '$cell')"
    else
      assert_eq 1 "$STATUS" "$tier without '$s' should be refused (the table says '$cell')"
      lower="$(tr '[:upper:]' '[:lower:]' <<<"${s:0:1}")${s:1}"
      assert_contains "$OUT" "$lower missing" "$tier without '$s' should name it"
    fi
  done
done

# 4. A past record (no tier line) passes with no check.
mkdir -p "$work/old"
printf '# Release: old\n\n## Version / target\n\n## Deploy steps run\n' >"$work/old/release.md"
run_check "$work/old"
assert_eq 0 "$STATUS" "an old-layout record should pass"
assert_contains "$OUT" "past record: no check"

# 5. The template's headings match the script's list: filled in as full, it passes.
mkdir -p "$work/template"
sed -E 's/^> Deploy tier: \{skip \| short \| full\}:/> Deploy tier: full:/' \
  "$REPO_ROOT/skills/session/templates/release.md" >"$work/template/release.md"
run_check "$work/template"
assert_eq 0 "$STATUS" "the release template, as full, should pass check-release.sh ($OUT)"

# 6. An unrecognised tier, and a missing record, are refused.
write_record "$work/bad-tier" huge ""
run_check "$work/bad-tier"
assert_eq 1 "$STATUS" "an unrecognised tier should be refused"
mkdir -p "$work/none"
run_check "$work/none"
assert_eq 1 "$STATUS" "a missing release.md should be refused"

echo "ok: check-release.sh checked"
exit 0
