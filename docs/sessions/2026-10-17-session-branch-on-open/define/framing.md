# Framing: Session opens on a feature branch

> Part of [index](index.md) · Define

## Problem checks

### Solution-first (XY)

- **Need behind the request:** session work reaches the repository's default branch only through a pull request merge. No session commit is pushed to the default branch directly, whether the session is opened, resumed or picked up on a branch the user already has.
- **Outcome:** the requested fix moved to Candidate solutions. The user confirmed the need is option (a), the guarantee above, not "create a branch at open" (2026-10-17).

**Candidate solutions:**
- Create a branch named `{type}/{issue}-{slug}` (past sessions used `feat/{issue}-{slug}`) in the New session flow, before the opening commit. This is what issue #37 proposes.
- Refuse any session commit or push whose target is the default branch.
- Create the branch at the first push rather than at the first commit.

### Symptom and cause

- **Observed symptom:** in #23, the opening commit `d38c99c` was pushed to `origin/main` and had to be reverted there with `912634c`. Then `origin/main` had to be merged back into the session branch to restore the session files [observed: `docs/sessions/archive/2026-09-25-define-phase-depth/log.md`, lines 102–103, 116 and 170]. Branches for later sessions, this one included, were created by hand [observed: this session's `log.md`; archived #27 and #28 logs].
- **Cause:** known and shown, in three parts:
  1. The New session flow's step 4 commits and pushes with no step before it that creates or checks a branch [observed: `skills/session/SKILL.md`, line 42; `docs/explanation/session/overview.md`, line 22].
  2. The #22 design placed branch creation at Implement ("One branch + one PR per session, created at Implement"), but the flow commits and pushes at Define, so the first push happens before any branch exists [observed: `docs/sessions/archive/2026-08-19-session-lifecycle/design.md`, line 172].
  3. Nothing checks which branch a session commit or push targets [observed: no branch check in `hooks/`].

## Anchor

- **State:** complete. The markers appear exactly once, and Vision, Mission, Scope and Non-goals are present and not empty. The README's other descriptions of the plugin (lines 3 and 7) link to the anchor instead of restating it.
- **Verdict:** aligns
- **Rests on:** Scope "Hooks and scripts that enforce session structure and traceability", "Session types: Feature (available)" and "Works in any repository, independent of tech stack" (which is why other repos' default branch names and naming conventions are in scope). Non-goal "Replacing user approval at milestones": opening and merging the PR stay the user's call.

### Anchor update

- **Action:** none
- **Elements:** none
- **Agreed text:**

none

## Overlaps

- **Construct registry:** none found. The registry's two constructs (ImplementStandard, BackendImplementGuidance) don't create, check or protect branches.
- **ADRs:** no conflict found in ADR-001 to ADR-005, none of which records a branch decision. ADR-002's "enforcement has to be mechanical" supports the hook constraint.
- **Earlier design (not an ADR):** the #22 design's D5 says the session branch is "created at Implement" (`docs/sessions/archive/2026-08-19-session-lifecycle/design.md`, line 172). This work changes that. Close should fold the change into `docs/explanation/session/overview.md`.
- **Pattern:** "Commit, push, then GitHub" (`docs/registry/patterns.md`) still applies, and this work keeps it.
