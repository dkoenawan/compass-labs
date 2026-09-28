---
session: 2026-09-28-design-phase-structure
type: feature
issue: 27
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
next_step: "User reviews define/ draft; relay REQ-028 choice + issue numbers to define"
---
# Session Log: Design phase structure — opinionated, layered design skills (#27)

> Format: D2. Only the orchestrator writes this file. Entries are append-only.
> Artifacts: [`define/index.md`](define/index.md) · [`design.md`](design.md) · [`tasks.md`](tasks.md) · [`verification.md`](verification.md) · [`release.md`](release.md)

## Open items

- #39 (visual, type-specific design artifacts with a current → new delta) is covered by this session alongside #27.
- Per-layer design work (frontend, backend, database) may be big enough for its own sub-issues. Flag and map them during Define and Design.

## Key decisions

- **2026-09-28**: Created #46/#47/#48 (frontend, backend and database layer sub-issues of #27) and #49/#50/#51 (process, infra and plugin kinds).
- **2026-09-28**: Framing confirmed: full tier. The layered structure is a candidate solution. Stack defaults, not mandates (anchor aligns). Three-tier gets depth now. Layers split to sub-issues. `plan` retired into Design. Handoff only for Implement. GitHub-native visuals. Two days.
- **2026-09-28**: Session covers #27 (primary) and #39 (refines #27) together.

---

## Phase: Define

### 2026-09-28 — main — note: session opened
- Issue #27 is primary and #39 is linked. Branch `feat/27-design-phase-structure`.
- User brief: Design today has no structure, much like Define before #23. Make it opinionated, with sub-skills chosen by the kind of solution. Step 1 identifies the solution type. For example, a three-tier software delivery app gets a whole-system design, then a deeper design for each layer:
  - frontend design;
  - backend design;
  - database changes, including whether they extend the current schema or add new tables, with pros and cons.
- Design currently overlaps with the `plan` skill. Consolidate them so the flow is Define (what) → Design (solution) → Implement (the design broken into tasks and test components for the implement and test agents).
- Per-layer sub-designs may become sub-issues. Flag and map them. Don't cut corners.
- Opinionated stack defaults:
  - frontend: React + TypeScript and the matching component ecosystem;
  - backend: Node.js, CQRS, Scalar API docs;
  - database: Postgres, managed through Prisma.
- #39 adds visual, type-specific design artifacts (for example BPMN 2.0 for process designs, architecture views for apps) with an explicit new, changed, deprecated and unchanged delta against the current state.

### 2026-09-28 — main — handoff: orchestrator → compass-labs:define (frame problem, write requirements)
- **Input:** frame the problem and write requirements for #27 + #39 from the user brief in the "session opened" note; propose a depth tier; stack defaults and layer structure are constraints, not a design.
- **Output:** needs_input (8 framing questions: tier, needs, stack vs anchor, solution kinds, delivery split, boundaries, rendering, appetite); no files changed

### 2026-09-28 — define — note: framing started; tier proposed full
- Proposed tier: full. The work adds a Design phase capability with per-layer sub-skills, changes the process every Feature session follows, consolidates `plan`, and likely spawns sub-issues. Awaiting the user's confirmation.
- #27's open question on `hooks/validate-spec.sh` is already closed: the hook was retired in #22 (`3c216c1`) and replaced by `session-guard.sh`.
- Anchor assessed as complete. The verdict depends on whether the stack defaults are mandates or defaults, because the Scope line says "independent of tech stack".
- Overlaps flagged:
  - #28 (Implement-phase domain skills per layer).
  - `skills/plan/` (Prisma/CQRS, DB → BE → FE spec).
  - ADR-003's Mermaid-only "Renderable" NFR vs BPMN 2.0 (#39).

### 2026-09-28 — define — decision: framing confirmed — full tier, scope split and constraints
- The user confirmed the full tier. The work adds a Design capability with per-layer extension points, changes every Feature session's process, retires `plan`, and splits off sub-issues.
- Needs NEED-01 to NEED-04 were confirmed. The classification step and the whole-system → per-layer structure are stakeholder-supplied candidate solutions and constraints: Design must address them but may shape them.
- The stack defaults (React + TS / Node.js + CQRS + Scalar / Postgres + Prisma) are defaults, not mandates, and an established repo stack wins. The anchor verdict is *aligns*, with anchor-update action `none`.
- Classification recognises every solution kind. Three-tier gets depth in this session; the other kinds are follow-ups.
- This session delivers the Design skill, the classification step, the whole-system design, the visual/delta standard (#39) and the layer framework. The frontend, backend and database in-depth designs become sub-issues of #27.
- `plan` is retired into Design. Only the Design → Implement handoff is in scope; Implement changes are a follow-up. Per layer, the design sub-skill and #28's Implement skill share one structure.
- Visuals must render natively on GitHub: Mermaid where possible, otherwise a committed SVG next to the non-Mermaid source in `assets/`.
- Appetite: two focused days.

### 2026-09-28 — define — attempt: full-tier define/ draft written
- `define/` was written with all six files. REQ-001 to REQ-024 are live (19 Must, 5 Should), OUT-01 to OUT-04 are each served, and all nine ISO/IEC 25010:2023 characteristics are covered or N/A with a reason.
- Seven Deferred rows (REQ-025 to REQ-031) wait for issue numbers from the orchestrator.
- #27's open question on `hooks/validate-spec.sh` is closed: the hook was retired in #22 (`3c216c1`).

### 2026-09-28 — main — decision: follow-up issues created (REQ-025–027, 029–031)
- Sub-issues of #27, linked as GitHub sub-issues: #46 frontend layer (REQ-025), #47 backend layer (REQ-026), #48 database layer (REQ-027).
- Follow-ups for the other solution kinds: #49 process/workflow with BPMN (REQ-029), #50 infrastructure (REQ-030), #51 plugin/tooling (REQ-031).
- REQ-028 (Implement derives tasks and tests from the design): waiting for the user to choose between a new issue and folding it into #28.
