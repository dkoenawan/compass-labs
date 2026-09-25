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

echo "ok: check-traceability.sh validated"
exit 0
