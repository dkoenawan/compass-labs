#!/usr/bin/env bash
# session-log.sh
# Shared helper, sourced (not run directly) by hooks/session-guard.sh and
# hooks/session-commit-guard.sh: "does this log.md have an uncommitted
# D2 heading of a given type?" Both hooks need the exact same answer —
# session-guard.sh's frozen-artifact rule (D7/D8: a frozen artifact may
# only be amended alongside a fresh `decision` entry) and
# session-commit-guard.sh's Stop check (D8: a `decision`/`milestone`
# entry must be committed together with the artifact changes it
# describes) — so it's factored into one place instead of two near-
# identical copies drifting apart.

# session_log_has_uncommitted_heading <repo_root> <log_path> <grep_pattern>
# Returns 0 (true) if log_path, relative to repo_root, has an
# uncommitted D2 entry heading matching grep_pattern (an extended-regex
# fragment, e.g. '— decision:' or '— (decision|milestone):') among its
# UNCOMMITTED changes — i.e. added lines in `git diff HEAD` for a
# tracked-and-modified file, or the whole file's content if it's
# untracked (a brand-new log.md has nothing to diff against). Returns 1
# otherwise, including when git/grep themselves fail (fail toward "no
# uncommitted heading found" rather than erroring the caller).
session_log_has_uncommitted_heading() {
  local repo_root="$1" log_path="$2" grep_pattern="$3"

  [[ -f "$log_path" ]] || return 1

  local status
  status="$(git -C "$repo_root" status --porcelain -- "$log_path" 2>/dev/null || true)"

  if [[ "$status" == \?\?* ]]; then
    # Untracked: nothing committed yet, so the whole file is "uncommitted".
    grep -qE -- "$grep_pattern" "$log_path" 2>/dev/null && return 0 || return 1
  fi

  local diff_added
  diff_added="$(git -C "$repo_root" diff HEAD -- "$log_path" 2>/dev/null | grep '^+' | grep -v '^+++' || true)"
  grep -qE -- "$grep_pattern" <<<"$diff_added" && return 0 || return 1
}
