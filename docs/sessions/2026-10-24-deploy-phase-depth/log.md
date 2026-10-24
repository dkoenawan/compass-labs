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
active_agent: main
next_step: "Hand off to compass-labs:define — framing tier and scope (declaration mechanism only, or also a Deploy standard)"
---
# Session Log: Deploy phase depth (#30)

> Format: D2. Only the orchestrator writes this file. Entries are append-only.
> Artifacts: [`define/index.md`](define/index.md) · [`design/index.md`](design/index.md) · [`implement/`](implement/) · [`verification.md`](verification.md) · [`release.md`](release.md)

## Open items

- Follow-ups: #78 frontend, #79 backend, #80 database, #81 infrastructure (Terraform), #82 cloud provider references.
- Work is on branch `feat/30-deploy-phase-depth`; it reaches main through a PR.

## Key decisions

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
