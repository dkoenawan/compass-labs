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
active_agent: main
next_step: "Hand off to compass-labs:define to frame the problem and write requirements"
---
# Session Log: Design phase structure — opinionated, layered design skills (#27)

> Format: D2. Only the orchestrator writes this file. Entries are append-only.
> Artifacts: [`define/index.md`](define/index.md) · [`design.md`](design.md) · [`tasks.md`](tasks.md) · [`verification.md`](verification.md) · [`release.md`](release.md)

## Open items

- #39 (visual, type-specific design artifacts with a current → new delta) is covered by this session alongside #27.
- Per-layer design work (frontend, backend, database) may be big enough for its own sub-issues. Flag and map them during Define and Design.

## Key decisions

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
