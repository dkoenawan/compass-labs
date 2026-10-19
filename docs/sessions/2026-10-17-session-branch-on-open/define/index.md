# Define: Session opens on a feature branch

> Phase: Define | Started: 2026-10-17 | Status: Draft
> Relates to: Issue #37 · Session history: [`log.md`](../log.md)

## Contents

- [Requirements](requirements.md): the `REQ-*` table and any deferred requirements
- [Framing](framing.md): problem checks, anchor verdict and overlaps
- [Problem](problem.md): need, stakeholders, evidence and success outcomes

## Framing

- **Tier:** short. A focused change to how sessions open and resume, with a documented incident (#23) and no new phase or artifact. Confirmed by the user on 2026-10-17.
- **Verdict:** aligns with the project anchor. See [framing.md](framing.md).

## Problem statement

Session work can reach the default branch without a pull request. The New session flow commits and pushes before any branch exists, and nothing checks the target branch, which is how #23's opening commit landed on `main` and had to be reverted. This affects compass-labs maintainers and teams using the plugin in other repos. Needs: NEED-01, NEED-02. Outcomes: OUT-01. See [problem.md](problem.md).

## Scope

- Making the first session commit on a session branch, whether the session opens on the default branch or on an existing non-default branch: [REQ-001, REQ-002, REQ-003, REQ-007, REQ-010](requirements.md).
- Resuming a session on its own branch: [REQ-004](requirements.md).
- Blocking session commits and pushes that target the default branch, whatever its name: [REQ-005, REQ-006](requirements.md).
- Opening a draft pull request as soon as the session branch is first pushed, after asking the user, with merging left to the user: [REQ-008, REQ-009](requirements.md).

### Non-goals

- Sessions in a repo with no remote, or whose push fails. Tracked in #70.
- Changing a repository's branch protection, CI or merge settings.
- Moving archived or in-flight sessions onto new branches.
- Non-session git work done by the user while a session is active.

## Constraints

- The guarantee that no session commit or push reaches the default branch must be enforced by a hook. Prompt instructions alone are not enough (user, 2026-10-17; ADR-002).
- Works in any repository, independent of tech stack: the default branch's name and the team's branch naming can't be assumed (project anchor, Scope).
- Opening and merging the pull request stay the user's decisions (project anchor, Non-goal "Replacing user approval at milestones").
- Commit, then push, then the `gh` update, at every milestone (`docs/registry/patterns.md`).

## Decisions

- **REQ-008, when the pull request opens:** as soon as the session branch is first pushed, as a draft, after asking the user. This replaces "before the Deploy milestone" and the #22 design's D5 timing (user, 2026-10-19).
- **REQ-002, an existing non-default branch:** the orchestrator asks each time, because asking is cheap (user, 2026-10-19).
- **REQ-005, how wide the block is:** session commits only. The user's own git work is left alone (user, 2026-10-19).

## Open questions

None.
