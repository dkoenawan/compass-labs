---
name: SessionBranchGuard
type: Hook
layer: Shared
file: hooks/session-branch-guard.sh
status: built
planned_in: null
last_verified: null
---

# SessionBranchGuard

> Origin: #37

## Does

Blocks a session `git commit` made while the repository's default branch is checked out, and a session `git push` whose destination is the default branch, so session work reaches the default branch only through a pull request. It does NOT choose or switch the session branch (the `session` skill does), read the default branch itself (DefaultBranchLookup does), find open sessions (SessionLister does), or stop a pull request merge (the orchestrator's no-merge rule covers that, with no hook).

## Functional Requirements

- [ ] With a session open and the default branch checked out, a `git commit` is refused before it is made, with a message naming the default branch, and the default branch's head doesn't change.
- [ ] With a session open, a `git push` whose destination is the default branch (an explicit refspec, `HEAD` while it's checked out, `--all`, `--mirror`, `--branches`, or no refspec while it's checked out) is refused.
- [ ] The default branch is the one the repository's `origin` reports, so a repository whose default branch is `trunk` and which has no `main` is protected the same way.
- [ ] A commit on the session branch and `git push -u origin {session-branch}` are allowed.
- [ ] With no session open and nothing staged under `docs/sessions/`, Claude's commits and pushes are left alone.
- [ ] Bash calls that aren't a git commit or push, and every tool other than Bash, are allowed.
- [ ] When `jq`, a git repository, a collaborator script or an answer from DefaultBranchLookup is missing, the command is allowed with a warning on stderr.

## Proof

- method: null
- verified_by: null
- checklist_result: null
- test_file: tests/hooks/session_branch_guard_test.sh, tests/integration/session_branch_integration_test.sh

## Interface

```text
Event:    PreToolUse, matcher Bash   (hooks/hooks.json)
Stdin:    hook input JSON: tool_name, tool_input.command, cwd
Exit:     0 allow · 2 block (reason on stderr, naming the default branch)
Reads:    the command text, split into simple commands on && || ; | & ( ) and newlines;
          `git -C dir` and an earlier `cd dir` set the repository
Session:  open when SessionLister prints any session, or the index has staged docs/sessions/ paths
```

## Dependencies

- Calls: DefaultBranchLookup, SessionLister (both resolved relative to the hook, inside the plugin), `git`, `jq`
- Called by: Claude Code, before every Bash tool call
- Reads: the repository's current branch and index
- Writes: nothing

## Patterns Applied

- [Session work reaches the default branch only through a pull request](../../registry/patterns.md#session-work-reaches-the-default-branch-only-through-a-pull-request)
- [Hooks fail open](../../registry/patterns.md#hooks-fail-open)
- [Plugin paths vs. project paths](../../registry/patterns.md#plugin-paths-vs-project-paths)

## Key Decisions

- [ADR-006](../../registry/decisions/006-session-branch-guard.md): a `PreToolUse` hook on `Bash`, not git hooks in the consuming repo; it reads command text, so `sh -c`, `eval`, aliases and scripts can get past it.
