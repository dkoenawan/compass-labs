#!/usr/bin/env bash
# gh_milestone_test.sh
# Exercises skills/session/scripts/gh-milestone.sh against a stub `gh` on
# PATH. No real GitHub calls.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=../lib.sh
source "$REPO_ROOT/tests/lib.sh"

SCRIPT="$REPO_ROOT/skills/session/scripts/gh-milestone.sh"

work_dir="$(mktemp -d)"
bin_dir="$work_dir/bin"
log_file="$work_dir/gh.log"
labels_file="$work_dir/labels.txt"
comments_file="$work_dir/comments.txt"
comment_body="$work_dir/comment.md"
trap 'rm -rf "$work_dir"' EXIT

install_stub_gh "$bin_dir"
export PATH="$bin_dir:$PATH"
export GH_STUB_LOG="$log_file"
export GH_STUB_LABELS_FILE="$labels_file"
export GH_STUB_COMMENTS_FILE="$comments_file"

echo "Design complete. Moving to Implement." > "$comment_body"

# 1. Normal transition: label not yet swapped, no existing comment.
echo "phase:design" > "$labels_file"
: > "$comments_file"
: > "$log_file"
out="$(bash "$SCRIPT" 22 design implement "$comment_body" 2>&1)"
status=$?
assert_eq "0" "$status" "gh-milestone.sh should exit 0"
assert_not_contains "$out" "SYNC_PENDING" "no gh failures expected"
assert_contains "$out" "moved to phase:implement" "should report the label move"
assert_contains "$out" "posted milestone comment" "should report the comment post"
remove_call="$(grep -c -- '--remove-label phase:design' "$log_file" || true)"
add_call="$(grep -c -- '--add-label phase:implement' "$log_file" || true)"
assert_eq "1" "$remove_call" "should remove the from-phase label"
assert_eq "1" "$add_call" "should add the to-phase label"

# 2. Idempotent: already in target label state -> label swap skipped.
echo "phase:implement" > "$labels_file"
: > "$comments_file"
: > "$log_file"
out="$(bash "$SCRIPT" 22 design implement "$comment_body" 2>&1)"
assert_contains "$out" "label swap skipped" "already-in-target-state should skip the swap"
edit_calls="$(grep -c '^issue edit' "$log_file" || true)"
assert_eq "0" "$edit_calls" "no issue edit calls expected when already in target state"

# 3. Idempotent: comment with the marker already exists -> comment skipped.
echo "phase:design" > "$labels_file"
echo "Some earlier comment <!-- compass:milestone:implement -->" > "$comments_file"
: > "$log_file"
out="$(bash "$SCRIPT" 22 design implement "$comment_body" 2>&1)"
assert_contains "$out" "already posted" "marker match should skip posting a duplicate comment"
comment_calls="$(grep -c '^issue comment' "$log_file" || true)"
assert_eq "0" "$comment_calls" "no issue comment calls expected when the marker already exists"

# 4. from-phase "none" (first milestone) never tries to remove a label.
echo "" > "$labels_file"
: > "$comments_file"
: > "$log_file"
out="$(bash "$SCRIPT" 22 none define "$comment_body" 2>&1)"
assert_not_contains "$out" "SYNC_PENDING" "no gh failures expected"
remove_calls="$(grep -c '\-\-remove-label' "$log_file" || true)"
assert_eq "0" "$remove_calls" "from-phase none should never remove a label"

# 5. gh failure -> SYNC_PENDING, exit 0.
echo "phase:design" > "$labels_file"
: > "$comments_file"
: > "$log_file"
export GH_STUB_FAIL=edit
out="$(bash "$SCRIPT" 22 design implement "$comment_body" 2>&1)"
status=$?
unset GH_STUB_FAIL
assert_eq "0" "$status" "gh-milestone.sh should exit 0 even when gh fails"
assert_contains "$out" "SYNC_PENDING" "a gh edit failure should be reported as SYNC_PENDING"

echo "ok: gh-milestone.sh validated"
exit 0
