#!/usr/bin/env bash
# lib.sh
# Shared assertion + fixture helpers for tests/**/*_test.sh.
# Sourced by test files (not run directly). Each test file should exit 0 on
# success and exit non-zero (e.g. via `fail`) on the first failed assertion.

set -uo pipefail

# Absolute path to the repo root, computed once relative to this file.
TESTS_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$TESTS_LIB_DIR/.." && pwd)"

# fail <message>
# Prints a failure message to stderr and exits 1.
fail() {
  echo "FAIL: $*" >&2
  exit 1
}

# assert_eq <expected> <actual> [message]
assert_eq() {
  local expected="$1" actual="$2" msg="${3:-values differ}"
  if [[ "$expected" != "$actual" ]]; then
    fail "$msg (expected: '$expected', got: '$actual')"
  fi
}

# assert_contains <haystack> <needle> [message]
assert_contains() {
  local haystack="$1" needle="$2" msg="${3:-expected string not found}"
  if [[ "$haystack" != *"$needle"* ]]; then
    fail "$msg (looking for '$needle')"
  fi
}

# assert_not_contains <haystack> <needle> [message]
assert_not_contains() {
  local haystack="$1" needle="$2" msg="${3:-unexpected string found}"
  if [[ "$haystack" == *"$needle"* ]]; then
    fail "$msg (did not expect '$needle')"
  fi
}

# run_hook <script_path> <json_stdin>
# Runs a hook script with the given JSON on stdin. Sets HOOK_EXIT,
# HOOK_STDOUT, HOOK_STDERR for the caller to assert on. Never lets the
# hook's own exit code kill the test process.
run_hook() {
  local script="$1" json="$2"
  local out_file err_file
  out_file="$(mktemp)"
  err_file="$(mktemp)"

  set +e
  echo "$json" | bash "$script" >"$out_file" 2>"$err_file"
  HOOK_EXIT=$?
  set -e 2>/dev/null || true

  HOOK_STDOUT="$(cat "$out_file")"
  HOOK_STDERR="$(cat "$err_file")"
  rm -f "$out_file" "$err_file"
}

# assert_hook_exit <script_path> <json_stdin> <expected_exit_code> [message]
# Convenience wrapper: runs the hook and asserts its exit code in one call.
assert_hook_exit() {
  local script="$1" json="$2" expected="$3" msg="${4:-hook exit code mismatch}"
  run_hook "$script" "$json"
  assert_eq "$expected" "$HOOK_EXIT" "$msg"
}

# assert_hook_stderr_contains <needle> [message]
# Checks HOOK_STDERR from the most recent run_hook/assert_hook_exit call.
assert_hook_stderr_contains() {
  local needle="$1" msg="${2:-expected stderr not found}"
  assert_contains "$HOOK_STDERR" "$needle" "$msg"
}

# make_temp_git_repo
# Creates an isolated temporary git repo (not the real repo) and prints its
# path. Callers should `rm -rf` it when done, or rely on the OS temp cleanup.
make_temp_git_repo() {
  local dir
  dir="$(mktemp -d)"
  git -C "$dir" init -q
  git -C "$dir" config user.email "test@example.com"
  git -C "$dir" config user.name "Test"
  echo "$dir"
}

# make_session_fixture <repo_dir> <slug> [phase] [status] [milestone]
# Creates docs/sessions/<slug>/ in the given fixture repo with a minimal
# log.md (D2 frontmatter) so hook tests don't touch the real repo's
# docs/sessions/. `milestone` is the phase KEY of the last completed
# milestone (none | define | design | implement | test | deploy | close),
# not a display label. Prints the session folder's absolute path.
make_session_fixture() {
  local repo_dir="$1" slug="$2" phase="${3:-implement}" status="${4:-active}" milestone="${5:-none}"
  local session_dir="$repo_dir/docs/sessions/$slug"
  mkdir -p "$session_dir/assets"

  cat >"$session_dir/log.md" <<EOF
---
session: $slug
type: feature
issue: 1
phase: $phase
status: $status
milestone: $milestone
active_agent: main
next_step: "test fixture"
---
# Session Log: $slug (#1)

## Open items

## Key decisions

---

## Phase: Define

### 2026-01-01 — main — note: fixture
- fixture entry
EOF

  echo "$session_dir"
}

# git_commit_all <repo_dir> [message]
# Stages and commits everything in the fixture repo, so later `git diff
# HEAD` / `git status` checks (e.g. the guard hook's frozen-artifact rule)
# have a real HEAD to compare against.
git_commit_all() {
  local repo_dir="$1" msg="${2:-fixture commit}"
  git -C "$repo_dir" add -A
  git -C "$repo_dir" commit -q -m "$msg"
}
