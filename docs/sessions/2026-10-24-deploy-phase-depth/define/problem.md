# Problem: Deploy phase depth

> Part of [index](index.md) · Define

*Agreed with the user on 2026-10-24 (tier full, scope: the declaration plus a Deploy standard, with compass-labs' merge-triggered pipeline as its first real L1 case).*

Deploy covers two lifecycles, and this problem statement keeps them apart:

- **L1, deployment setup.** It happens when a repo is started, and again whenever the repo's architecture changes during its life: a new microservice, a service bus, new infrastructure. In a full application, this is where the deployment pipelines for each part (frontend, backend, database, infrastructure) are created or updated.
- **L2, session release.** It happens when a session completes: whatever it takes to get this session's change to staging or production. For a project like compass-labs it's the same every session: bump the version, push, and raise or ready the PR.

### Context

**Situation:** every Feature session ends with a Deploy phase. Its agent records the release in `release.md` [observed: `skills/session/workflows/feature.json`, `agents/deploy.md`]. Deploy has one firm rule, the release-completeness check, and the Deploy gate enforces it [observed: `agents/deploy.md`, `skills/session/SKILL.md` step a2]. Everything else is a bare template with six headings [observed: `skills/session/templates/release.md`]. The session-lifecycle session decided that what deploy means depends on the repo (Q9). How a repo says so was left open (Q14, deferred to #30) [observed: `2026-08-19-session-lifecycle/requirements.md`].

**Complication:** since then, Define, Design and Implement have each been given a standard skill with depth tiers. An SDLC depth review on 2026-10-24 found Deploy the thinnest phase [observed: orchestrator handoff, `log.md`]. Five compass-labs releases have gone through Deploy, and each one worked out from scratch what deploy means, with details drifting between runs [observed: `docs/sessions/archive/*/release.md`; see [framing.md](framing.md#symptom-and-cause)]. Deploy also treats every run as an L2 session release: nothing in the phase, template or gate recognises L1, where a repo's deployment setup has to be created or changed [observed: `agents/deploy.md`, `templates/release.md`]. And a consuming repo has no way to tell Deploy what either lifecycle involves for it [observed: `agents/deploy.md`, TODO #30].

### Need and stakeholders

- **NEED-01 (L2, compass-labs):** When a compass-labs session reaches Deploy, the plugin maintainer wants the routine release (bump the version, commit, push, mark the PR ready) to run on its own, with no prompts, from steps the repo declares once, so that all that's left for them is to merge the PR. Once they merge, they want whatever follows the merge (tagging `main` and publishing the release) to run as part of compass-labs' own deployment setup (L1), triggered by the merge, not as steps they run by hand.
- **NEED-02 (L2, consuming repo):** When a session in a consuming repo with a real deployment completes, that repo's maintainer wants Deploy to follow the repo's own declared path for getting the change to staging or production, and its declared check that the change worked, so that Deploy neither guesses nor stops on every run.
- **NEED-03 (both lifecycles, gate reviewer):** When the user reviews a release at the Deploy milestone, they want the release record to show, in one shape for every repo and at a depth that matches the work, which lifecycle ran, how the change was rolled out, how it was confirmed working, how to undo it and what change was made, so that they can approve or refuse it as confidently as they do at the earlier gates.
- **NEED-04 (L1, consuming repo):** When a repo is started, or a session changes its architecture (for example by adding a service, a service bus or new infrastructure), the repo's maintainer wants Deploy to recognise that the deployment setup has to be created or updated, and to deal with it as its own lifecycle separate from the session release, so that later session releases always have a deployment path that matches the architecture.

### Evidence

- `agents/deploy.md` says Deploy configuration is deferred and that the agent "currently has to work it out ad hoc each time" [observed: `agents/deploy.md`, TODO #30].
- All 5 archived release records explain again what "deploy" means for compass-labs and why `task release` can't run as one step (it tags a branch commit that the squash-merge throws away, and its bump commit message doesn't carry the issue reference) [observed: `docs/sessions/archive/*/release.md`].
- The tag name, and who does the version bump, changed between releases [observed: `2026-10-10-implement-phase-skills/release.md`, `2026-10-17-session-branch-on-open/release.md`].
- Every compass-labs release so far has been the same routine (bump, commit, push, PR, then the user's merge) [observed: the five archived `release.md` files]. Even so, steps such as the push and readying the PR were listed as "pending" for someone else to run [observed: `2026-10-17-session-branch-on-open/release.md`, steps 4 to 8]. The maintainer wants these to run without prompts [observed: the user, 2026-10-24].
- compass-labs has no CI. Tagging `main` and refreshing the plugin cache after the merge are done by hand, and are left as unchecked "pending" steps in the release record [observed: `2026-10-17-session-branch-on-open/release.md`, "There's no CI" and steps 9 to 12]. The tag name has drifted between releases [observed: same file]. The maintainer wants the steps after the merge to run as a pipeline the merge triggers, set up as compass-labs' own L1 in this session [observed: the user, 2026-10-24].
- Q9 said a compass-labs release runs as its own session. In practice every release has run inside the feature session [observed: `2026-08-19-session-lifecycle/log.md`; the five archived `release.md` files]. The user wants each repo to declare which it uses [observed: the user, 2026-10-24].
- Since #37, the session branch guard blocks a push to the default branch, so the steps after the merge are left to the user [observed: `2026-10-17-session-branch-on-open/release.md`, steps 9 to 12; ADR-006].
- Nothing in Deploy recognises L1. The template and the agent describe only a release [observed: `templates/release.md`, `agents/deploy.md`]. Elsewhere, setup work is only planned: `bootstrap-new-project` lists "CI/CD pipeline configuration" as a future enhancement [observed: `skills/bootstrap-new-project/SKILL.md`], and the infrastructure design path, which covers "Hosting, networking, deployment or cloud resources change", isn't written yet [observed: `skills/design/SKILL.md`, #50].
- Deploy isn't conversational. It returns `blocked` when the repo gives it no way to tell what deploy means [observed: `agents/deploy.md`].
- No consuming repo has run a compass-labs Deploy phase yet [observed: the user, 2026-10-24]. The non-plugin cases are tested on a fixture repo. compass-labs itself is the first real L1 case (its merge-triggered pipeline) [observed: the user, 2026-10-24].
- Without a shared standard, release records will differ from repo to repo in their confirmation and rollback detail [assumed. compass-labs' own five records are thorough because one maintainer wrote them, not because a standard asks for it].
- An architecture change made during a session, but with no matching deployment setup, shows up as a failed or partial release later on [assumed].

### Impact and why now

- **If nothing changes:**
  - Each compass-labs release keeps re-deriving its steps, keeps prompting for routine steps, leaves the steps after the merge to be done by hand, and risks drift (tag names, who does the bump, the feature branch or the default branch) [observed: the archived release records].
  - A consuming repo gets a Deploy that's either `blocked` or guessed [observed: `agents/deploy.md`], which goes against the anchor's scope line "Works in any repository".
  - Architecture changes go out without the deployment setup that matches them, because no phase recognises that L1 is needed [assumed].
  - At the Deploy gate the user approves a record with less behind it than the ones at earlier gates [observed: the SDLC depth review].
- **Why now:**
  - The earlier phases have all been given depth (#26, #27, #28), so Deploy is the clearest gap left before Close [observed: archived sessions `2026-09-25-define-phase-depth`, `2026-09-28-design-phase-structure`, `2026-10-10-implement-phase-skills`].
  - This session's own Deploy can try out the result on compass-labs' next release.

### Success outcomes

| Outcome | Signal | Target | Checked when | For need |
|---|---|---|---|---|
| OUT-01 | During this session's own Deploy on compass-labs: how many times the user is asked something before the merge, and where `release.md` gets its release steps from | No prompts before the merge. The version is bumped and committed, the branch is pushed, and the PR is marked ready. `release.md` names the repo's declaration as the source of the steps and doesn't re-derive them | This session's Deploy phase, and again at the next compass-labs release | NEED-01 |
| OUT-02 | What Deploy does in a repo with no deploy declaration | It stops before running any deploy step and tells the user how to declare one. It doesn't guess | Test phase, on a fixture repo with no declaration | NEED-02 |
| OUT-03 | What Deploy does in a repo that declares a real deployment | It runs the declared release steps and the declared check, and records both in `release.md`. Any step the repo marks as affecting production waits for the user's instruction | Test phase, on a fixture repo with a declaration that isn't a plugin release | NEED-02 |
| OUT-04 | Whether the release record has every section the Deploy standard requires at the session's tier, including which lifecycle ran, and whether the Deploy gate refuses a record that's missing one | Every required section is present, and the gate refuses a record that lacks one | This session's Deploy gate, and in Test on a record with a section missing | NEED-03 |
| OUT-05 | Whether Deploy tells L1 from L2: in a session that changes the architecture, or in a repo with no deployment setup yet, compared with a session that changes neither | In the first case, Deploy records that a setup is needed and deals with it before the release. In the second, it runs only the release | Test phase, on fixture repos for both cases | NEED-04 |
| OUT-06 | What happens on the remote after the user merges this session's PR into compass-labs' `main` | The merge triggers a pipeline that creates the release tag (one consistent name) on the merge commit and publishes the release, with no manual step from the user. This session's `release.md` records setting up the pipeline as an L1 run, and the session's release as an L2 run | When the user merges this session's PR, checked against the remote's tags and the pipeline's run record | NEED-01 |

### Appetite and no-gos

- **Appetite:** one session with the same budget as the earlier phase-depth sessions (#26, #27, #28) [observed: the user, 2026-10-24].
- **No-gos:** see [Non-goals](index.md#non-goals).
