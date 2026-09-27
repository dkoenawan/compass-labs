#!/usr/bin/env bash
# check_traceability_test.sh
# Exercises skills/session/scripts/check-traceability.sh (REQ-011 gate).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

SCRIPT="$REPO_ROOT/skills/session/scripts/check-traceability.sh"

work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

write_requirements() {
  cat > "$work_dir/requirements.md" <<'EOF'
# Requirements

| ID | Requirement | Acceptance criterion |
|---|---|---|
| REQ-001 | thing one | given/when/then |
| REQ-002 | thing two | given/when/then |
EOF
}

# 1. Every REQ has a passing VER -> exit 0.
write_requirements
cat > "$work_dir/verification.md" <<'EOF'
| ID | Covers REQ | Method | Result | Evidence |
|---|---|---|---|---|
| VER-001 | REQ-001 | unit | pass | ci run 1 |
| VER-002 | REQ-002 | e2e | pass | ci run 2 |
EOF
out="$(bash "$SCRIPT" "$work_dir" 2>&1)"
status=$?
assert_eq "0" "$status" "all REQs covered by passing VERs should exit 0"
assert_contains "$out" "ok:" "should print an ok message"

# 2. A REQ with no VER row at all -> exit 1, named as missing.
write_requirements
cat > "$work_dir/verification.md" <<'EOF'
| ID | Covers REQ | Method | Result | Evidence |
|---|---|---|---|---|
| VER-001 | REQ-001 | unit | pass | ci run 1 |
EOF
out="$(bash "$SCRIPT" "$work_dir" 2>&1)"
status=$?
assert_eq "1" "$status" "a REQ with no VER should exit 1"
assert_contains "$out" "REQ-002" "the missing REQ should be named"

# 3. A REQ whose only VER failed -> exit 1.
write_requirements
cat > "$work_dir/verification.md" <<'EOF'
| ID | Covers REQ | Method | Result | Evidence |
|---|---|---|---|---|
| VER-001 | REQ-001 | unit | pass | ci run 1 |
| VER-002 | REQ-002 | e2e | fail | ci run 2 |
EOF
out="$(bash "$SCRIPT" "$work_dir" 2>&1)"
status=$?
assert_eq "1" "$status" "a REQ whose only VER failed should exit 1"
assert_contains "$out" "REQ-002" "the failing REQ should be named"

# 4. Missing verification.md entirely -> exit 1 (script error, not a pass).
write_requirements
rm -f "$work_dir/verification.md"
bash "$SCRIPT" "$work_dir" >/dev/null 2>&1
status=$?
if [[ $status -eq 0 ]]; then
  fail "missing verification.md should not exit 0"
fi

# --- define/ layout (#23 DES-019) ------------------------------------
# Cases 1-4 above are the root-layout fallback (past sessions, D6).

# write_define_requirements <dir>: the same REQ content as
# write_requirements, under define/requirements.md, in the 5-column
# table, plus a Deferred table (D8) whose row names a REQ in column 2.
write_define_requirements() {
  local dir="$1"
  mkdir -p "$dir/define"
  cat > "$dir/define/requirements.md" <<'EOF'
# Requirements

| ID | Requirement | Priority | Serves | Acceptance criterion |
|---|---|---|---|---|
| REQ-001 | thing one | Must | OUT-01 | given/when/then |
| REQ-002 | thing two | Should | NEED-01 | given/when/then |

## Deferred

| Follow-up | Was | Requirement | Reason |
|---|---|---|---|
| #999 | REQ-003 | thing three | later |
EOF
}

# 5. (b) Same content under define/ -> same exit code as case 1.
define_dir="$(mktemp -d)"
write_define_requirements "$define_dir"
cat > "$define_dir/verification.md" <<'EOF'
| ID | Covers REQ | Method | Result | Evidence |
|---|---|---|---|---|
| VER-001 | REQ-001 | unit | pass | ci run 1 |
| VER-002 | REQ-002 | e2e | pass | ci run 2 |
EOF
out="$(bash "$SCRIPT" "$define_dir" 2>&1)"
status=$?
assert_eq "0" "$status" "define/ layout with every REQ covered should exit 0"
assert_contains "$out" "define/requirements.md" "should report the define/ file it read"

# 6. (b, e) Same missing IDs as case 2; the Deferred row (REQ-003) has no
#    VER and is never reported missing.
cat > "$define_dir/verification.md" <<'EOF'
| ID | Covers REQ | Method | Result | Evidence |
|---|---|---|---|---|
| VER-001 | REQ-001 | unit | pass | ci run 1 |
EOF
out="$(bash "$SCRIPT" "$define_dir" 2>&1)"
status=$?
assert_eq "1" "$status" "define/ layout with a REQ missing a VER should exit 1"
assert_contains "$out" "REQ-002" "define/ layout should name the missing REQ"
assert_not_contains "$out" "REQ-003" "a Deferred row should never be named as missing"

# 7. define/requirements.md is read in preference to a root file.
cat > "$define_dir/requirements.md" <<'EOF'
| ID | Requirement | Acceptance criterion |
|---|---|---|
| REQ-900 | root only | given/when/then |
EOF
out="$(bash "$SCRIPT" "$define_dir" 2>&1)"
assert_not_contains "$out" "REQ-900" "define/requirements.md should be read in preference to the root file"
rm -rf "$define_dir"

# 8. (d) Neither file exists -> exit 1, naming both paths.
empty_dir="$(mktemp -d)"
cat > "$empty_dir/verification.md" <<'EOF'
| ID | Covers REQ | Method | Result | Evidence |
|---|---|---|---|---|
EOF
out="$(bash "$SCRIPT" "$empty_dir" 2>&1)"
status=$?
assert_eq "1" "$status" "no requirements file in either layout should exit 1"
assert_contains "$out" "$empty_dir/define/requirements.md" "the error should name the define/ path"
assert_contains "$out" "$empty_dir/requirements.md" "the error should name the root fallback path"
rm -rf "$empty_dir"

echo "ok: check-traceability.sh validated"
exit 0
