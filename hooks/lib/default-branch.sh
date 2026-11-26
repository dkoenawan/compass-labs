#!/usr/bin/env bash
# default-branch.sh [repo-path]
# Prints the repository's default branch name, as its `origin` remote
# reports it, and exits 0 (#37 DES-001, REQ-006, D6). Never assumes
# `main`.
#
# Sources, in order:
#   1. `git symbolic-ref --short refs/remotes/origin/HEAD` (local, instant;
#      `git clone` always sets it), with the leading `origin/` stripped.
#   2. `git ls-remote --symref origin HEAD` (asks the remote itself), under
#      a short timeout so a slow network can't stall the caller. The
#      timeout is DEFAULT_BRANCH_LS_REMOTE_TIMEOUT seconds (default 5).
#
# Exits 1 with a reason on stderr when repo-path isn't a git repository,
# there is no `origin` remote (no remote at all is #70's), or neither
# source answers. Callers (the branch guard hook) fail open on exit 1.
# Read-only: never fetches, never sets origin/HEAD.

set -uo pipefail

repo="${1:-.}"

if ! git -C "$repo" rev-parse --git-dir >/dev/null 2>&1; then
  echo "default-branch: not a git repository: $repo" >&2
  exit 1
fi

if ! git -C "$repo" remote get-url origin >/dev/null 2>&1; then
  echo "default-branch: no 'origin' remote in $repo, so the default branch can't be read" >&2
  exit 1
fi

# 1. origin/HEAD symbolic ref.
ref="$(git -C "$repo" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)"
if [[ -n "$ref" ]]; then
  name="${ref#origin/}"
  if [[ -n "$name" && "$name" != "$ref" ]]; then
    echo "$name"
    exit 0
  fi
fi

# 2. Ask the remote, with a short timeout and no credential prompt.
timeout_secs="${DEFAULT_BRANCH_LS_REMOTE_TIMEOUT:-5}"
timeout_cmd=()
if command -v timeout >/dev/null 2>&1; then
  timeout_cmd=(timeout "$timeout_secs")
fi

out="$(GIT_TERMINAL_PROMPT=0 "${timeout_cmd[@]}" git -C "$repo" ls-remote --symref origin HEAD 2>/dev/null || true)"
# The symref line looks like: "ref: refs/heads/trunk<TAB>HEAD".
name="$(awk '$1 == "ref:" && $3 == "HEAD" { sub("^refs/heads/", "", $2); print $2; exit }' <<<"$out")"

if [[ -n "$name" ]]; then
  echo "$name"
  exit 0
fi

echo "default-branch: neither origin/HEAD nor 'git ls-remote --symref origin HEAD' named a default branch for $repo" >&2
exit 1
