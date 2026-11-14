#!/usr/bin/env bash
# stubs_test.sh
# DES-008: the triage stubs never touch the real GitHub, crontab or claude.
# The stub gh logs and serves fixtures; the stub crontab is backed by a file
# and refuses one outside TMPDIR; the stub claude logs its argv and prompt.

set -uo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
triage_setup

[[ "$(command -v gh)" == "$TRIAGE_STUBS/gh" ]] || fail "stub gh should be first on PATH"
[[ "$(command -v crontab)" == "$TRIAGE_STUBS/crontab" ]] || fail "stub crontab should be first on PATH"
[[ "$(command -v claude)" == "$TRIAGE_STUBS/claude" ]] || fail "stub claude should be first on PATH"

# gh: logs argv, serves fixtures, forced failures.
issue_json 1 "One" | jq -s . >"$GH_STUB_DIR/issues.json"
out="$(gh issue list --state open --json number)"
assert_eq "1" "$(jq -r '.[0].number' <<<"$out")" "stub gh should serve issues.json"
assert_eq "issue list --state open --json number" "$(gh_calls)" "stub gh should log argv"
assert_eq "maint" "$(gh api user --jq .login)" "stub gh api user"
GH_STUB_FAIL=auth gh auth status 2>/dev/null && fail "forced auth failure should exit 1"
gh auth status 2>/dev/null || fail "auth status should pass by default"
echo body >"$T/b.md"
url="$(GH_STUB_NEW_NUMBER=42 gh issue create --title "Triage x" --body-file "$T/b.md")"
assert_eq "https://github.com/stub/repo/issues/42" "$url" "issue create URL"
assert_eq "body" "$(cat "$GH_STUB_DIR/created-body.md")" "issue create keeps the body"
assert_eq "Triage x" "$(cat "$GH_STUB_DIR/created-title")" "issue create keeps the title"
gh issue view 9 2>/dev/null && fail "issue view of a missing fixture should fail"
assert_contains "$(gh_writes)" "issue create" "gh_writes should list the create"

# crontab: file-backed, refuses outside TMPDIR.
crontab -l 2>/dev/null && fail "crontab -l with no file should exit 1"
printf 'a\nb\n' | crontab - || fail "crontab - should write the file"
assert_eq $'a\nb' "$(crontab -l)" "crontab -l should print the file"
CRONTAB_STUB_FILE="/var/tmp/not-under-tmpdir-$$" crontab -l >/dev/null 2>&1
assert_eq "99" "$?" "stub crontab must refuse a file outside TMPDIR"
[[ -e "/var/tmp/not-under-tmpdir-$$" ]] && fail "stub crontab wrote outside TMPDIR"

# claude: logs argv one per line, the cwd and the prompt; prints the report.
echo "REPORT" >"$T/r.md"
out="$(cd "$T" && echo "PROMPT" | CLAUDE_STUB_REPORT="$T/r.md" claude -p --tools "Read,Grep,Glob")"
assert_eq "REPORT" "$out" "stub claude prints the report"
assert_eq $'-p\n--tools\nRead,Grep,Glob\n--cwd '"$T" "$(cat "$CLAUDE_STUB_LOG")" "stub claude argv log"
assert_eq "PROMPT" "$(cat "$CLAUDE_STUB_LOG.prompt")" "stub claude keeps the prompt"

exit 0
