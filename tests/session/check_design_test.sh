#!/usr/bin/env bash
# check_design_test.sh
# Exercises skills/session/scripts/check-design.sh (#27 DES-011, REQ-017,
# REQ-024): each missing heading is named, a complete index passes, the
# real template passes, and a legacy design.md gets no check.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

SCRIPT="$REPO_ROOT/skills/session/scripts/check-design.sh"
[[ -x "$SCRIPT" ]] || fail "check-design.sh not found or not executable"

work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

# write_index <session-dir> <heading to leave out, or "">
write_index() {
  local dir="$1" skip="$2" h
  mkdir -p "$dir/design"
  {
    echo "# Design: test"
    for h in "Prior knowledge" "Classification" "Scope checklist" "Context view" "Delta list" \
      "Components (DES)" "Decisions" "Principles check" "Risks" "Open questions"; do
      [[ "$h" == "$skip" ]] && continue
      printf '\n## %s\n\nbody\n' "$h"
    done
  } > "$dir/design/index.md"
}

# run_check <session-dir>: sets CHECK_EXIT and CHECK_OUT (stdout + stderr).
run_check() {
  CHECK_OUT="$(bash "$SCRIPT" "$1" 2>&1)"
  CHECK_EXIT=$?
}

# 1. A complete index passes.
s="$work_dir/complete"
write_index "$s" ""
run_check "$s"
assert_eq 0 "$CHECK_EXIT" "a complete design/index.md should pass"
assert_contains "$CHECK_OUT" "ok"

# 2. Each missing heading is refused and named.
for pair in "Classification|classification" "Scope checklist|scope checklist" \
  "Context view|context view" "Delta list|delta list missing"; do
  heading="${pair%%|*}"
  expect="${pair#*|}"
  s="$work_dir/missing-${heading// /-}"
  write_index "$s" "$heading"
  run_check "$s"
  assert_eq 1 "$CHECK_EXIT" "missing '$heading' should be refused"
  assert_contains "$CHECK_OUT" "$expect" "missing '$heading' should be named"
done

# 3. Several missing headings are all named.
s="$work_dir/bare"
mkdir -p "$s/design"
printf '# Design\n\n## Risks\n' > "$s/design/index.md"
run_check "$s"
assert_eq 1 "$CHECK_EXIT" "an index with none of the gate's sections should be refused"
for label in "classification" "scope checklist" "context view" "delta list"; do
  assert_contains "$CHECK_OUT" "$label missing"
done

# 4. A heading at the wrong level doesn't count.
s="$work_dir/wrong-level"
write_index "$s" "Delta list"
printf '\n### Delta list\n' >> "$s/design/index.md"
run_check "$s"
assert_eq 1 "$CHECK_EXIT" "a level-3 'Delta list' heading should not satisfy the check"

# 5. The real template passes (its headings match what the gate checks).
s="$work_dir/template"
mkdir -p "$s/design"
cp "$REPO_ROOT/skills/session/templates/design/index.md" "$s/design/index.md"
run_check "$s"
assert_eq 0 "$CHECK_EXIT" "the design/index.md template should pass check-design.sh"

# 6. Legacy layout: only a root design.md -> no check, exit 0.
s="$work_dir/legacy"
mkdir -p "$s"
printf '# Design: old\n\n## Approach\n' > "$s/design.md"
run_check "$s"
assert_eq 0 "$CHECK_EXIT" "a legacy design.md should get no check"
assert_contains "$CHECK_OUT" "legacy layout: no check"

# 7. Neither layout -> error.
s="$work_dir/empty"
mkdir -p "$s"
run_check "$s"
assert_eq 1 "$CHECK_EXIT" "a session with no design should fail"
assert_contains "$CHECK_OUT" "design not found"

echo "ok: check-design.sh validated"
exit 0
