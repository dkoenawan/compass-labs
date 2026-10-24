# Framing: Deploy phase depth

> Part of [index](index.md) · Define

## Problem checks

### Solution-first (XY)

- **Need behind the request:** whoever runs a session's Deploy phase needs the repo to say once what deploy means for it, in two separate lifecycles. **L1, deployment setup**, happens when the repo starts and whenever its architecture changes. **L2, session release**, happens when a session completes. With that declared, Deploy does the same thing every run instead of working it out again, and runs a routine release such as compass-labs' without prompts. Whoever approves the Deploy milestone needs the release record to show, in the same shape every time, which lifecycle ran, what was shipped, how, how it was confirmed, and how to undo it.
- **Outcome:** the requested fix moved to Candidate solutions. #30 names four ways a repo could declare deploy, and picking one is a Design decision. The user put a Deploy standard in scope (scope b, 2026-10-24) as a need in its own right: NEED-03 in [problem.md](problem.md).

**Candidate solutions:**
- From #30 and session-lifecycle Q14: a config file, a skill specific to the repo, a Taskfile target, or a `CLAUDE.md` section.
- From the SDLC depth review (2026-10-24): a Deploy standard skill (like `framing`/`problem-statement`/`requirements`, `design` and `implement`) covering release strategy, rollback, post-deploy confirmation and a change record, based on established practice. Examples to weigh in Design: SRE release engineering, ITIL 4 change enablement, DORA's change failure rate and time to restore, SemVer and Keep a Changelog.
- Implied by every past release: a release sequence that fits squash-merge (bump on the branch; tag and cache refresh on the default branch after the merge), since `task release` can't run as one step.
- For compass-labs' steps after the merge: a pipeline triggered by the merge that tags `main` and publishes the release. Which mechanism (a hosted CI service or something else) is left to Design.
- For L1: Deploy finds out an architecture change from the session's frozen `design/` artifact (for example a new container in the C4 view). The other way is for the repo to declare its deployable parts.

### Symptom and cause

- **Observed symptom:**
  - The Deploy agent works out what "deploy" means from scratch every run [observed: `agents/deploy.md`, TODO #30].
  - All five archived `release.md` files explain again what deploy means for compass-labs and why `task release` can't run as one step [observed: `docs/sessions/archive/*/release.md`].
  - Details changed between releases: the tag name (`v2.1.0` against `compass-labs--v*`), who does the version bump [observed: `2026-10-10-…` and `2026-10-17-…/release.md`], and whether Deploy runs in its own session or inside the feature session [observed: `2026-08-19-session-lifecycle/log.md`, Q9 and the override on 2026-09-25].
  - Nothing in Deploy treats deployment setup (L1) as different from a release (L2) [observed: `agents/deploy.md`, `templates/release.md`].
- **Cause:** partly known. There's no way for a repo to declare deploy, because Q14 deferred that choice to #30 [observed: `2026-08-19-session-lifecycle/requirements.md`, Q14]. Two further causes are **assumed**, not shown: that the missing Deploy standard leaves records without a shared shape for confirmation, rollback and the change record, and that having no idea of L1 lets an architecture change ship without matching deployment setup.

## Anchor

- **State:** complete. The markers appear exactly once (README lines 11 and 44). Vision, Mission, Scope and Non-goals are all present and not empty. The one restatement outside the markers (README line 7) links to the anchor, so the restatement check passes.
- **Verdict:** aligns (checked again against the confirmed scope b, the L1/L2 split, and compass-labs' own merge-triggered pipeline).
- **Rests on:**
  - Scope: "Standards for each session artifact, by session type and depth tier." (`release.md` is a Feature artifact, and today it has a template but no standard behind it.)
  - Scope: "Works in any repository, independent of tech stack." (A repo declaring its own deploy is how Deploy meets this line. Guidance for each layer and each cloud is deferred, so this session stays independent of stack.)
  - Non-goal: "A runtime, framework or hosted service." (The work must not turn compass-labs into a deploy runner or CD service. The repo's own tooling and pipelines run the deploy. compass-labs' merge-triggered pipeline is this repo's own release tooling, not something the plugin ships or hosts for other repos.)
  - Non-goal: "Replacing user approval at milestones." (The Deploy milestone and the PR merge stay the user's call. Running the declared routine steps without prompts happens before the gate and doesn't replace it.)
  - Non-goal: "Creating new methods where an established one exists." (The Deploy standard is based on established release and change practice.)

### Anchor update

- **Action:** none
- **Elements:** none
- **Agreed text:**

none

## Overlaps

- **Registry constructs:** none found. No construct in `docs/registry/index.md` does deploy, release or deployment setup.
- **Pattern, not overlap:** the release-completeness pattern (`docs/registry/patterns.md`, around line 34). The work must keep it.
- **ADR-002 (session lifecycle):** no conflict. Deploy stays a fixed Feature phase with one artifact (`release.md`) and one owner. A declaration in the consuming repo isn't a session artifact. Making `release.md` a folder would follow the pattern ADR-003, -004 and -005 set, and that's a Design question. The session guard only watches `docs/sessions/`, so declared steps that edit repo files (such as a version bump) aren't blocked by it [observed: `hooks/session-guard.sh`].
- **ADR-006 (session branch guard):** no conflict, but it limits the work. Session pushes to the default branch are blocked, and the PR merge stays the user's call. Running the routine compass-labs steps without prompts (bump, commit, push the session branch, mark the PR ready) stays within ADR-006. The pipeline after the merge runs on the remote once the user has merged, so it isn't a session push to the default branch. Design must confirm it doesn't depend on Claude pushing to `main`.
- **`bootstrap-new-project` and `init` (#38):** L1 at repo start interacts with them. `bootstrap-new-project` lists "CI/CD pipeline configuration" as a future enhancement, and `init` sets up a project for compass-labs. Neither declares deploy today, so there's no duplication. Design decides whether L1's first run hooks into them or runs at a session's Deploy.
- **The infrastructure design path (#50):** related. Design's infrastructure kind ("Hosting, networking, deployment or cloud resources change") has no in-depth path yet. L1 could take its trigger from Design's output, and the per-layer depth is deferred to #78 to #82 (see [index.md](index.md#non-goals)).
- **#20 (cloud-agnostic Terraform scaffolding):** related, no overlap found. An L1 setup in a consuming repo may point to that infrastructure code, but compass-labs doesn't run Terraform itself. Judged from how the repo refers to #20, not from the issue body.
- **#31 (hook-based stage transition automation):** related, no overlap found. #31 automates moving between phases, while this work decides what happens inside Deploy. It stays out of scope, as in the session-lifecycle session (`2026-08-19-session-lifecycle/requirements.md`, line 122).
- **#72 and #36:** out of scope. #72 belongs to Close. #36 wasn't examined.
