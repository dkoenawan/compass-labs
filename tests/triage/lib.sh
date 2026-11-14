#!/usr/bin/env bash
# tests/triage/lib.sh
# Helpers for tests/triage/*_test.sh, on top of tests/lib.sh. Sourced, not
# run. triage_setup puts the stubs in tests/triage/stubs/ first on PATH and
# points every stub, and the run log, at a fresh directory under TMPDIR, so
# no triage test touches the real GitHub, crontab, claude or home directory.

# shellcheck source=../lib.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/lib.sh"

TRIAGE_SKILL_DIR="$REPO_ROOT/skills/triage"
TRIAGE_SCRIPTS="$TRIAGE_SKILL_DIR/scripts"
TRIAGE_STUBS="$REPO_ROOT/tests/triage/stubs"

# triage_setup
# Sets and exports T (work dir), GH_STUB_DIR, GH_STUB_LOG, CLAUDE_STUB_LOG,
# CRONTAB_STUB_FILE, CRONTAB_STUB_LOG, XDG_STATE_HOME, TRIAGE_GH_BIN and
# TRIAGE_CLAUDE_BIN, and prepends the stubs to PATH. Clears forced failures.
triage_setup() {
  export TMPDIR="${TMPDIR:-/tmp}"
  T="$(mktemp -d)"
  export T
  export GH_STUB_DIR="$T/gh" GH_STUB_LOG="$T/gh.log"
  export CLAUDE_STUB_LOG="$T/claude.log"
  export CRONTAB_STUB_FILE="$T/crontab" CRONTAB_STUB_LOG="$T/crontab.log"
  export XDG_STATE_HOME="$T/state"
  export TRIAGE_GH_BIN="$TRIAGE_STUBS/gh" TRIAGE_CLAUDE_BIN="$TRIAGE_STUBS/claude"
  export PATH="$TRIAGE_STUBS:$PATH"
  unset GH_STUB_FAIL GH_STUB_NEW_NUMBER CLAUDE_STUB_REPORT CLAUDE_STUB_EXIT TRIAGE_NOW
  export GH_STUB_LOGIN="maint"
  mkdir -p "$GH_STUB_DIR" "$XDG_STATE_HOME"
  : > "$GH_STUB_LOG"
}

# make_triage_repo [anchor|noanchor]
# A fixture git repo with one commit and a README, with or without the
# project anchor markers. Prints its path.
make_triage_repo() {
  local kind="${1:-anchor}" dir
  dir="$(make_temp_git_repo)"
  if [[ "$kind" == anchor ]]; then
    cat >"$dir/README.md" <<'MD'
# Fixture

<!-- compass:anchor -->
## Project anchor

### Vision

Fixture vision.

### Mission

Fixture mission.

### Scope

- Fixture scope line.
<!-- /compass:anchor -->

More text.
MD
  else
    printf '# Fixture\n\nNo anchor here.\n' >"$dir/README.md"
  fi
  mkdir -p "$dir/src" && echo 'echo hi' >"$dir/src/app.sh"
  git_commit_all "$dir" "fixture"
  echo "$dir"
}

# issue_json <number> <title> [author] [updatedAt] [createdAt]
# One issue object in `gh issue list --json` shape.
issue_json() {
  jq -n --argjson n "$1" --arg t "$2" --arg a "${3:-alice}" \
    --arg u "${4:-2026-11-01T00:00:00Z}" --arg c "${5:-2026-10-01T00:00:00Z}" \
    '{number:$n,title:$t,body:("Body of #"+($n|tostring)),labels:[],comments:[],
      author:{login:$a},createdAt:$c,updatedAt:$u,state:"OPEN",closedAt:null}'
}

# gh_calls
# The stub gh log, one call per line.
gh_calls() { cat "$GH_STUB_LOG" 2>/dev/null; }

# gh_writes
# Lines of the stub gh log that would change GitHub.
gh_writes() {
  grep -E '^(issue (create|close|comment|edit|reopen|delete|lock|transfer|pin)|label (create|edit|delete)|pr (create|merge|close|comment|edit|review|ready|reopen))' "$GH_STUB_LOG" 2>/dev/null || true
}
