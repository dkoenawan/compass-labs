<!-- tier: skip, short, full. The main doc (D12). Every tier has it. Summarise and link; never restate a sub-doc's content. -->
# Define: Deploy phase depth

> Phase: Define | Started: 2026-10-24 | Status: Approved 2026-10-24
> Relates to: Issue #30 · Session history: [`log.md`](../log.md)

## Contents

- [Requirements](requirements.md): REQ-001 to REQ-025, and the deferred per-layer and per-cloud work (#78 to #82)
- [Framing](framing.md): problem checks, anchor verdict and overlaps
- [Problem](problem.md): the two deploy lifecycles, context, needs, evidence, impact, success outcomes and appetite
- [Quality](quality.md): ISO/IEC 25010:2023 coverage, the NFR measure for REQ-024, assumptions and dependencies
- [Diagrams](diagrams.md): impact map, context diagram, traceability, and as-is/to-be for a compass-labs release

## Framing

- **Tier:** full (confirmed by the user, 2026-10-24). The work changes a phase every Feature session goes through. It touches the Deploy agent, its template, the Deploy gate and a contract consuming repos follow, and there's a real risk of fixing only the symptom.
- **Verdict:** aligns with the project anchor. See [framing.md](framing.md).

## Problem statement

Deploy is the thinnest phase. It treats every run as a release and has no notion of deployment setup. Deploy has two lifecycles: **L1, deployment setup**, when a repo starts or its architecture changes, and **L2, session release**, when a session completes. A repo has no way to declare what either one means for it. So the Deploy agent works deploy out again on every run, compass-labs' routine release still waits on prompts and its steps after the merge are done by hand, and a consuming repo has nothing to declare at all. Apart from the completeness check, the release record has no standard behind it. Needs: NEED-01, NEED-02, NEED-03, NEED-04. Outcomes: OUT-01 to OUT-06. See [problem.md](problem.md).

## Scope

*Agreed with the user, 2026-10-24.*

- How a repo declares what deploy means for it, covering both lifecycles. For L2, the declaration includes whether a release runs inside the feature session or as its own session.
- How Deploy tells L1 from L2: when a deployment setup is needed (a repo with no setup yet, or a session that changes the architecture) and when only a release is.
- Running a repo's declared routine release steps without prompts, and stopping when there's no declaration.
- A Deploy standard for the release record: which lifecycle ran, the release strategy, post-deploy confirmation, rollback and the change record, with depth tiers and based on established frameworks, at the same depth as the Define, Design and Implement standards.
- compass-labs' own declaration, used in this session's own Deploy.
- compass-labs' own L1 deployment setup: a pipeline triggered by the merge that does what follows it (tagging `main`, publishing the release), so that no step after the merge is done by hand. This is the first real L1 case, and this session's Deploy runs both lifecycles on it. The mechanism is Design's choice.
- The general case, tested on a fixture repo (no consuming repo has run Deploy yet).

### Non-goals

*Agreed with the user, 2026-10-24.*

- What deploy means for each layer, including generating or updating the pipeline for each part. This session separates L1 from L2; the per-layer depth is future work:
  - frontend: #78
  - backend: #79
  - database: #80
  - infrastructure (Terraform): #81
- References for each cloud (what Azure, AWS or GCP does for each lifecycle): #82.
- compass-labs running deployments itself as a runtime, CD tool or hosted service (an anchor non-goal).
- Automating the move from one phase to the next with hooks: #31.
- Infrastructure scaffolding or provisioning: #20.
- Close's issue-before-merge ordering: #72. Also #36.
- Changing the release-completeness check, apart from keeping it.

## Constraints

*Agreed with the user, 2026-10-24.*

- Merging the PR, and any step that affects production, runs only on the user's own instruction. A repo's declared routine release steps run without prompts: for compass-labs, bump the version, commit, push the session branch and mark the PR ready (the user, 2026-10-24; the no-merge rule). Steps after the merge run in the repo's merge-triggered pipeline (its L1 setup), not by an agent pushing to the default branch.
- Session work reaches the default branch only through a pull request (ADR-006).
- Deploy keeps its fixed place in the Feature workflow and its one owning agent. Inside the session folder, that agent writes only its own artifact (ADR-002, the phase-agent contract).
- The Deploy milestone still needs the user's approval (an anchor non-goal: not replacing user approval).
- Anything a repo declares works in any repository, whatever its tech stack, and stays optional for a repo that has no deploy at all (anchor scope).
- The Deploy standard is based on established frameworks, not a new method (an anchor non-goal).
- The release-completeness check stays as it is, and still comes before any deploy step.
- Past sessions' `release.md` files are never migrated.

## Open questions

- **Tagging after the merge (compass-labs): resolved.** Tagging `main` and publishing the release run as a pipeline triggered by the merge. That pipeline is compass-labs' L1 setup, and it's set up in this session (the user, 2026-10-24). See Scope and OUT-06.
- **Refreshing the plugin cache (for Design):** the refresh (`claude plugin update`, then restarting Claude) runs on the user's own machine, against their local install. A remote pipeline triggered by the merge probably can't do it [assumed]. Design decides whether it stays a user step, written into the release record, or moves to some local trigger.
- **Who runs the routine steps (for Design):** whether the Deploy agent or the orchestrator runs the bump, commit, push and PR-ready steps is left to Design. Today the commit and `gh` steps sit with the orchestrator.
- **The release session (for Design):** REQ-012 says only what a feature session does when the declaration says a release runs as its own session. What that release session is, and how it collects the changes waiting for it, is left to Design. No criterion asserts a result for it.
- **Settled at the Define gate (2026-10-24):**
  - The version bump is chosen by the declared rule without a prompt, and the user can refuse it at the gate (REQ-005). Confirmed.
  - The release tag form is `compass-labs--v{version}` (REQ-019 to REQ-022). Confirmed.
  - Release-record depth: Deploy proposes its own tier from the release's risk, and the user confirms it at the Deploy gate. It doesn't follow the session's framing tier (REQ-014, REQ-015, REQ-025).
- **Deploy tiers (for Design):** which tiers Deploy has, and the risk that points to each, are set in the Deploy standard (REQ-014).
