---
id: "006"
date: 2026-10-20
status: Accepted
deciders: [Daniel Koenawan]
affects: [session, SessionBranchGuard, DefaultBranchLookup, SessionLister]
issue: https://github.com/dkoenawan/compass-labs/issues/37
---

# ADR-006: Session work reaches the default branch only through a pull request, enforced by a `PreToolUse` hook on `Bash`

> Origin: #37

## Context

A session commits and pushes at every milestone, and Implement commits once per task. Nothing in the lifecycle checked which branch those commits landed on, so a session opened or resumed with the default branch checked out committed and pushed straight to it. Undoing that means a revert on the default branch and a repair of the session branch by hand.

Constraints: [ADR-002](002-session-lifecycle.md) holds that lifecycle rules have to be enforced mechanically, because agents drift from prompt-only rules. The plugin is distributed publicly, so it runs in repositories whose default branch may not be `main`, may be protected, and may already have its own git hooks (husky, lefthook, a team `core.hooksPath`). The guarantee covers session commits only: the user's own git work in their own terminal must be left alone. Every plugin hook fails open rather than leaving a repo unable to work.

## Decision

We will enforce the rule with a **Claude Code `PreToolUse` hook on the `Bash` tool**, `hooks/session-branch-guard.sh`, shipped with the plugin and registered in `hooks/hooks.json`. It reads the command text of each Bash call and blocks (exit 2) a `git commit` made while the default branch is checked out, and a `git push` whose destination is the default branch.

- **The default branch is read from the repository**, never assumed: `origin/HEAD`, then `git ls-remote --symref origin HEAD` (`skills/session/scripts/default-branch.sh`).
- **A call counts as a session commit** while any session is active or paused, in the working tree or at the tip of any local branch (`skills/session/scripts/list-sessions.sh`), or while paths under `docs/sessions/` are staged. With no session open, Claude's own commits are left alone.
- **It fails open** with a warning when `jq` is missing, the directory isn't a git repository, a collaborator script is missing, or the default branch can't be read.

The hook is the mechanical half. The `session` skill does the rest in prose: the session branch is chosen and checked out before the first commit, recorded in `log.md`'s `branch:` field, switched back to on Resume, and the orchestrator never merges the session's pull request unless the user's own message asks it to.

This **refines [ADR-002](002-session-lifecycle.md)**: it adds an enforcement point (a hook on `Bash`, beside the existing guards on file writes and on `Stop`) without changing the lifecycle itself.

## Options Considered

| Option | Pros | Cons | Why rejected |
|--------|------|------|--------------|
| **`PreToolUse` hook on `Bash` that reads `git commit` and `git push` (chosen)** | Same mechanism as the other session guards; ships with the plugin, so nothing is installed into the consuming repo; sees only commands Claude runs, so the user's own terminal git is untouched | Reads command text, so an unusual form (`sh -c "git commit"`, `eval`, a git alias, a script that commits) can get past it | — chosen |
| Git `pre-commit` and `pre-push` hooks installed into the consuming repo | Catches every commit, however it's made | Also blocks the user's own git work unless it can tell Claude apart; writes into `.git/hooks` or `core.hooksPath`, which clashes with husky, lefthook and team setups; needs an install step | Breaks the "session commits only" constraint and the consuming repo's own git setup |
| Prompt-only rule in the `session` skill | No new hook | Agents drift; a single missed step pushes to the default branch | ADR-002: enforcement has to be mechanical |

## NFR Captured

- Scope: only Bash calls Claude makes are checked. The user's own terminal git never passes through the hook.
- Cost: a Bash call that doesn't mention both `git` and `commit` or `push` exits at once. The branch scan runs only for a `git commit` or `git push`.
- Latency: the `git ls-remote` fallback runs only when `origin/HEAD` is unset, and is capped by `DEFAULT_BRANCH_LS_REMOTE_TIMEOUT` (default 5 seconds) before failing open.
- Portable: works with any git host, and with a default branch of any name.

## Consequences

**Now easier**: Opening or resuming a session from a default-branch checkout without the risk of pushing to it; using the plugin in a repo whose default branch is `trunk`, `master` or anything else.
**Now harder**: While any session is open in a repo, Claude can't commit to the default branch at all, even for work unrelated to the session; that work goes on a branch too.
**New constraints**: Session commits are made with plain `git` commands the hook can read. A new commit or push form Claude starts using must be recognised by the hook's command reader, or it bypasses the guard. The no-merge rule for the orchestrator has no hook behind it: a hard block on `gh pr merge` would also stop the merge the user asks for.

## Revisit Conditions

If a session commit reaches the default branch through a command form the hook can't read, or if Claude Code gains a way to observe git operations directly (rather than command text), re-evaluate the mechanism. The cases the guard doesn't cover yet are tracked separately: a repo with no `origin` remote or a failed push (#70), and a session that has already been archived, which the guard no longer counts as open (#73).
