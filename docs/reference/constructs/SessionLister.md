---
name: SessionLister
type: Utility
layer: Shared
file: skills/session/scripts/list-sessions.sh
status: built
planned_in: null
last_verified: null
---

# SessionLister

> Origin: #37

## Does

Lists every active or paused session, from the working tree and from the tip of every local branch, so a session whose folder exists only on its own branch is still found. It does NOT switch branches, fetch, read `docs/sessions/archive/`, or decide anything from the list (Resume, `session-start.sh` and SessionBranchGuard do).

## Functional Requirements

- [ ] With `main` checked out and an active session committed only on `feat/5-widget`, it lists that session as found on `feat/5-widget`, without switching branch.
- [ ] An untracked `log.md` with `status: active` in the working tree is listed.
- [ ] A session under `archive/`, or with `status: archived`, is never listed.
- [ ] A session in the working tree is listed once, from the working tree, even when a branch also has a copy; among branch copies, the copy on the branch its own `branch:` names wins.
- [ ] It exits 0 when nothing is listed, and when the path isn't a git repository.

## Proof

- method: null
- verified_by: null
- checklist_result: null
- test_file: tests/session/list_sessions_test.sh

## Interface

```text
Usage:  bash ${CLAUDE_PLUGIN_ROOT}/skills/session/scripts/list-sessions.sh [repo-path]
Stdout: one line per session, tab-separated:
        {slug}  {status}  {branch it was found on}  {recorded branch:, or -}
        {slug} is the folder name; a working-tree session's "found on" is the checked-out branch (HEAD when detached)
Exit:   always 0
```

## Dependencies

- Calls: `git for-each-ref refs/heads`, `git grep`, `git show`, `git symbolic-ref`
- Called by: SessionBranchGuard, `hooks/session-start.sh`, `skills/session/SKILL.md` (Mode dispatch and Resume)
- Reads: `docs/sessions/*/log.md` frontmatter (`status`, `branch`) in the working tree and at every local branch tip
- Writes: nothing

## Patterns Applied

- [Session work reaches the default branch only through a pull request](../../registry/patterns.md#session-work-reaches-the-default-branch-only-through-a-pull-request)
- [Plugin paths vs. project paths](../../registry/patterns.md#plugin-paths-vs-project-paths)

## Key Decisions

- [ADR-006](../../registry/decisions/006-session-branch-guard.md): a session counts as open for the branch guard while it is active or paused at any local branch tip, not only in the working tree.
