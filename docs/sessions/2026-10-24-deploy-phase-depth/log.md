---
session: 2026-10-24-deploy-phase-depth
type: feature
issue: 30
# branch: the session branch, written once when the session opens, read by Resume.
branch: feat/30-deploy-phase-depth
phase: define
status: active
# milestone: the PHASE KEY of the last completed milestone, not a display
# label. Allowed values (feature workflow): none | define | design |
# implement | test | deploy | close. "none" until the first milestone
# (Define complete) is reached. The guard hook (D7) uses this key, plus
# each phase's `order` in workflows/<type>.json, to decide which
# artifacts are frozen. Display labels (e.g. "Define complete") live only
# in workflows/<type>.json's `milestone` field, for GitHub comments.
milestone: none
active_agent: compass-labs:define
next_step: "compass-labs:define writes requirements.md, quality.md and diagrams.md"
---
# Session Log: Deploy phase depth (#30)

> Format: D2. Only the orchestrator writes this file. Entries are append-only.
> Artifacts: [`define/index.md`](define/index.md) · [`design/index.md`](design/index.md) · [`implement/`](implement/) · [`verification.md`](verification.md) · [`release.md`](release.md)

## Open items

- Follow-ups: #78 frontend, #79 backend, #80 database, #81 infrastructure (Terraform), #82 cloud provider references.
- Work is on branch `feat/30-deploy-phase-depth`; it reaches main through a PR.

## Key decisions

- **2026-10-24**: Requirements approved — REQ-001 to REQ-025 (16 Must, 7 Should, 2 Could); Deploy proposes its own tier by release risk, confirmed at the Deploy gate; bump picked by declared rule; tag form compass-labs--v{version}.
- **2026-10-24**: Problem agreed for #30 — full tier, scope (b) declaration + Deploy standard; two lifecycles L1 deployment setup / L2 session release; NEED-01–04, OUT-01–06; compass-labs routine release runs without prompts and a merge-triggered pipeline (its L1 setup) tags and publishes; anchor aligns, no update.
- **2026-10-24**: Follow-ups filed — #78 frontend, #79 backend, #80 database, #81 infrastructure (Terraform), #82 cloud provider references (per-part and per-cloud deploy depth, a non-goal of #30).
---

## Phase: Define

### 2026-10-24 — main — note: Session opened
- Issue #30 (Configure Deploy phase per repo). Picked after an SDLC depth review: Define and Design deep, Implement medium, Test thin, Deploy thinnest (`agents/deploy.md` works deploy out ad hoc; TODO #30).
- Branch `feat/30-deploy-phase-depth`, created from `main`.

### 2026-10-24 — main — note: Draft PR opened
- https://github.com/dkoenawan/compass-labs/pull/77 (draft, `feat/30-deploy-phase-depth` → `main`, Refs #30).

### 2026-10-24 — main — handoff: orchestrator → compass-labs:define (framing and problem for #30)
- **Input:** Run framing for #30. Scope is open: the declaration mechanism alone (config file, repo skill, Taskfile target or CLAUDE.md section), or also a Deploy standard (release strategy, rollback, post-deploy checks, change record) to match the depth Define/Design/Implement got. Context: SDLC depth review found Deploy the thinnest phase. Consider both cases, compass-labs' own plugin release and a consuming repo's real deployment; check overlap with #20 and #31.
- **Output:** needs_input; define/index.md, define/framing.md (new), define/problem.md (new)

### 2026-10-24 — compass-labs:define — attempt: Framing and problem statement drafted for #30
- Proposed tier: full (it changes a phase every Feature session goes through: the Deploy agent, its template, its gate, and a contract consuming repos follow). Awaiting the user's confirmation.
- Anchor complete; verdict aligns (draft). Anchor update: none. Overlaps: none in the registry; ADR-002 and ADR-006 limit the work; #20 and #31 related, no overlap.
- Evidence: all 5 archived release.md files re-derive what deploy means for compass-labs; the tag name and who does the bump changed between releases; Q9's "release as its own session" was overridden every time.
- Drafted NEED-01 to NEED-03 and OUT-01 to OUT-04 (NEED-03 and OUT-04 apply only if a Deploy standard is in scope). Scope, constraints, non-goals and appetite put to the user. No requirements yet.

### 2026-10-24 — compass-labs:define — attempt: Problem statement and constraints revised for two deploy lifecycles
- The user confirmed tier full and scope (b): the declaration plus a Deploy standard. Q9: the repo declares in-session or separate release. No real consuming repo, so non-plugin cases use a fixture repo. Appetite: same as #26 to #28.
- Problem split into L1 (deployment setup: repo start, architecture change) and L2 (session release). Needs NEED-01 to NEED-04; outcomes OUT-01 to OUT-05 (NEED-04 and OUT-05 are the new L1 need and outcome).
- Constraint revised: PR merge and production-affecting steps only on the user's instruction; declared routine release steps (for compass-labs: bump, commit, push, PR ready) run without prompts. ADR-006 and the no-merge rule unchanged.
- Per-layer and per-cloud deploy depth made non-goals; five follow-up issues proposed. Overlaps added: bootstrap-new-project, init (#38), #50. Anchor still aligns. Awaiting the user's confirmation; no requirements yet.

### 2026-10-24 — main — decision: Follow-ups filed for per-part and per-cloud deploy depth
- Per the user's choice of five issues: #78 frontend, #79 backend, #80 database, #81 infrastructure (Terraform), #82 cloud provider references. Each links back to this session.

### 2026-10-24 — compass-labs:define — decision: Problem statement, constraints and non-goals agreed for #30
- Tier full; scope (b): a per-repo deploy declaration plus a Deploy standard. Anchor verdict aligns; no anchor update.
- Two lifecycles: L1 deployment setup (when a repo starts, and whenever its architecture changes) and L2 session release (when a session completes). Needs NEED-01 to NEED-04; outcomes OUT-01 to OUT-06 (define/problem.md).
- compass-labs: routine release steps (bump, commit, push the session branch, mark the PR ready) run without prompts. What follows the merge (tagging main, publishing the release) runs as a pipeline triggered by the merge: compass-labs' own L1 setup, in scope for this session and its first real L1 case (OUT-06). Mechanism left to Design.
- Constraints: PR merge and production-affecting steps only on the user's instruction; ADR-006 and the no-merge rule unchanged; one Deploy owner writing only its artifact in the session folder; the Deploy milestone still needs approval; declarations work in any repo and are optional; the standard is based on established frameworks; the completeness check is kept; past release.md files are not migrated.
- Q9: each repo declares whether a release runs inside the feature session or as its own session. Non-plugin cases are tested on a fixture repo. Appetite: same as #26 to #28.
- Non-goals: per-layer deploy depth, frontend #78, backend #79, database #80, infrastructure (Terraform) #81; cloud provider references #82; compass-labs as a deploy runner; #31; #20; #72 and #36; changing the completeness check.
- Open for Design: whether the plugin cache refresh (local to the user's machine) stays a user step; whether the Deploy agent or the orchestrator runs the routine steps.

### 2026-10-24 — compass-labs:define — note: Requirements set drafted for #30 (awaiting the user's approval)
- define/requirements.md: REQ-001 to REQ-024 (15 Must, 7 Should, 2 Could; no live Won't). Every OUT-01 to OUT-06 is served; REQ-012, REQ-013, REQ-016 and REQ-017 serve needs directly.
- OUT-06 has a check before the merge (REQ-019: a check run that reports the tag it would create) and checks after it (REQ-020 to REQ-024: tag and release on the merge commit with no user step, no tag without a version change, never overwrite a tag, the user's remaining steps listed, tag visible within 10 minutes).
- Deferred: #78 frontend, #79 backend, #80 database, #81 infrastructure (Terraform), #82 cloud provider references.
- define/quality.md: 25010:2023 coverage (Safety N/A with a reason), the NFR measure for REQ-024 (Goal 10 min, Tolerable 30), assumptions and dependencies. define/diagrams.md: impact map, context, traceability, as-is/to-be.
- Assumptions to confirm: version bump chosen by the declared rule without a prompt; release-record depth follows the framing tier; tag form compass-labs--v{version}. Open for Design: local cache refresh, who runs the routine steps, what a separate release session is.

### 2026-10-24 — compass-labs:define — decision: Requirements set approved for #30
- The user approved define/requirements.md at the Define gate: REQ-001 to REQ-025 (16 Must, 7 Should, 2 Could; no live Won't), serving OUT-01 to OUT-06. Deferred: #78 frontend, #79 backend, #80 database, #81 infrastructure (Terraform), #82 cloud provider references.
- Change at the gate: Deploy proposes its own depth tier from the release's risk (e.g. a routine plugin bump vs a production change) and the user confirms it at the Deploy gate; it doesn't follow the session's framing tier. REQ-014 (the standard states the risk that points to each tier) and REQ-015 (the gate checks against the confirmed Deploy tier) revised; REQ-025 added (Deploy proposes and records its tier and reason; the gate asks the user to confirm).
- Assumptions confirmed: the version bump is picked by the declared rule without a prompt and can be refused at the gate; tag form compass-labs--v{version}.
- quality.md, diagrams.md and index.md updated to match; define/index.md status set to Approved 2026-10-24.
- Open for Design: the Deploy tiers and their risk signals, the local plugin-cache refresh, who runs the routine steps, what a separate release session is.
