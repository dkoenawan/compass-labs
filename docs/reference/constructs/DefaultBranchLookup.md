---
name: DefaultBranchLookup
type: Utility
layer: Shared
file: skills/session/scripts/default-branch.sh
status: built
planned_in: null
last_verified: null
---

# DefaultBranchLookup

> Origin: #37

## Does

Prints the repository's default branch name as its `origin` remote reports it, never assuming `main`. It does NOT fetch, set `origin/HEAD`, look at any remote other than `origin`, or decide what to do with the answer (SessionBranchGuard and the `session` skill do).

## Functional Requirements

- [ ] In a repository whose `origin` default branch is `trunk` and which has no `main`, it prints `trunk` and exits 0, both with `origin/HEAD` set and with it removed.
- [ ] With `origin/HEAD` unset, it asks the remote (`git ls-remote --symref origin HEAD`) under a short timeout, with no credential prompt.
- [ ] With no `origin` remote, an unreachable `origin` and no `origin/HEAD`, or a path that isn't a git repository, it exits 1 with a reason on stderr.

## Proof

- method: null
- verified_by: null
- checklist_result: null
- test_file: tests/session/default_branch_test.sh

## Interface

```text
Usage:   bash ${CLAUDE_PLUGIN_ROOT}/skills/session/scripts/default-branch.sh [repo-path]
Stdout:  the default branch name (e.g. "main", "trunk")
Exit:    0 named · 1 no answer (reason on stderr)
Sources: 1. git symbolic-ref --short refs/remotes/origin/HEAD  (leading origin/ stripped)
         2. git ls-remote --symref origin HEAD, under DEFAULT_BRANCH_LS_REMOTE_TIMEOUT seconds (default 5)
```

## Dependencies

- Calls: `git`, `timeout` when available
- Called by: SessionBranchGuard, `skills/session/SKILL.md` (New session branch step)
- Reads: the repository's `origin` remote and `refs/remotes/origin/HEAD`
- Writes: nothing

## Patterns Applied

- [Session work reaches the default branch only through a pull request](../../registry/patterns.md#session-work-reaches-the-default-branch-only-through-a-pull-request)

## Key Decisions

- [ADR-006](../../registry/decisions/006-session-branch-guard.md): the default branch is read from the repository with plain git, so it works with any host; a repository with no `origin` gets no answer and its callers fail open (#70).
