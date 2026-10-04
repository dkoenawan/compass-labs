---
session: 2026-09-28-design-phase-structure
type: feature
issue: 27
phase: design
status: active
# milestone: the PHASE KEY of the last completed milestone, not a display
# label. Allowed values (feature workflow): none | define | design |
# implement | test | deploy | close. "none" until the first milestone
# (Define complete) is reached. The guard hook (D7) uses this key, plus
# each phase's `order` in workflows/<type>.json, to decide which
# artifacts are frozen. Display labels (e.g. "Define complete") live only
# in workflows/<type>.json's `milestone` field, for GitHub comments.
milestone: define
active_agent: main
next_step: "Design gate: user approves design.md (#55 deferred)"
---
# Session Log: Design phase structure — opinionated, layered design skills (#27)

> Format: D2. Only the orchestrator writes this file. Entries are append-only.
> Artifacts: [`define/index.md`](define/index.md) · [`design.md`](design.md) · [`tasks.md`](tasks.md) · [`verification.md`](verification.md) · [`release.md`](release.md)

## Open items

- #39 (visual, type-specific design artifacts with a current → new delta) is covered by this session alongside #27.
- Per-layer design work (frontend, backend, database) may be big enough for its own sub-issues. Flag and map them during Define and Design.
- #55: a quality reference (cited source plus pass/fail checklist) for each notation in the catalogue. Deferred from the Design gate as an enhancement.

## Key decisions

- **2026-10-04**: Notation quality standards (a cited source plus a checklist for each notation) deferred to #55 as an enhancement. No REQ added and Define stays frozen.
- **2026-09-28**: Design choices settled. Plugin/tooling kind. ADRs written at Close. notations.md catalogue. Flowchart + table delta. design/ folder + check-design.sh. Design agent gets Bash (render only). skills/{layer}/ home. No stubs. plan deleted. stack-defaults.md. Claude Design zip + PNGs.
- **2026-09-28**: ✅ Define complete — 30 live REQs, 9 deferred (#46–#54), anchor aligns.
- **2026-09-28**: REQ-035 stays Design-only; widening it to every phase is deferred to #54 (REQ-039).
- **2026-09-28**: Design reads prior knowledge only from the Diátaxis docs, never past sessions (REQ-035/036). SOLID, YAGNI and KISS are checked on every choice and DES item, and unneeded items are rejected (REQ-037/038).
- **2026-09-28**: Retiring brand-designer deferred to #53 (REQ-034).
- **2026-09-28**: One primary kind plus a scope checklist (REQ-001/002). Design depth matches Define (REQ-032). Claude Design handoff (REQ-033). Terraform is the infrastructure default (REQ-008–010). Documented SVG route only (REQ-015). Anchor still aligns.
- **2026-09-28**: REQ-028 → #52. Mixed solutions: one primary kind plus an in-scope checklist. Design depth matches Define. Visual UI design is delegated to Claude Design (handoff only). Infrastructure is always Terraform.
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

### 2026-09-28 — main — decision: REQ-028 follow-up created as #52; open-question answers and two new constraints
- The user chose a new issue for REQ-028 after checking that none exists (#28 covers per-layer Implement skills, not task derivation). Created #52.
- Open-question answers:
  - **SVG rendering:** use a documented route when rendering isn't possible. Three-tier uses C4, which Mermaid renders natively. The user believes the Design agent has Bash, but `agents/design.md` grants only Read, Glob, Grep, Write and Edit (flagged).
  - **Mixed solutions:** one primary kind, plus a checklist of what else might be in scope (for example, a three-tier app still has infrastructure), not grouping by kind.
  - **Design depth:** Design depth matches the Define tier and scope; a smaller scope gets a thinner design.
  - **ADRs inline or linked, and notation per kind:** Design's choice. ADRs stay grouped together with the other docs.
- New constraint: **visual UI design is delegated to Claude Design.** The frontend layer covers components and functionality (React). `brand-designer` shouldn't manage visual design; this repo's sessions only hand off to Claude Design.
- New constraint: **infrastructure is always Terraform.** Noted on #50; related to #20.
- **Output (relay 2):** needs_input (issue number for the brand-designer deferral); define/ index, framing, requirements, quality, diagrams updated

### 2026-09-28 — define — decision: open questions answered, Claude Design and Terraform constraints added
- Classification gives one primary kind plus a scope checklist of the areas that might be in scope, rather than several kinds (REQ-001, REQ-002).
- Design depth matches Define's tier and scope, with no separate Design tiers (new REQ-032).
- Visual UI design is delegated to Claude Design. The frontend layer covers components and functionality only. The Design path gets a Claude Design handoff (new REQ-033). #46 inherits the split.
- Retiring or redirecting `brand-designer` is deferred (REQ-034) because of the appetite and because it changes the anchor's "brand design" Scope line. The follow-up issue runs its own anchor check.
- Terraform is the infrastructure stack default and, like the others, yields to an established repo stack (REQ-008 to REQ-010; related #20, #50).
- Non-Mermaid visuals need only a documented SVG render route this session (REQ-015). Three-tier designs use C4 in Mermaid.
- ADR placement, notation declaration, delta encoding, a `design/` folder and granting Bash to the Design agent stay Design's choices. The user leans towards ADRs grouped in the registry.
- The anchor verdict is unchanged: *aligns*, with update action `none`.

### 2026-09-28 — define — attempt: define/ updated with issue numbers and new constraints
- Deferred rows carry #46–#52. REQ-034 waits on a follow-up issue number for the `brand-designer` retirement.
- There are 26 live requirements (21 Must, 5 Should). Quality coverage, assumptions, dependencies and all four diagrams are updated.

### 2026-09-28 — main — decision: brand-designer retirement deferred to #53 (REQ-034)
- Created #53, linked to #27 and this session. It owns the anchor Scope change for "brand design".
- **Output (relay 3):** done; define/ requirements, index, framing updated (#53 swapped in)

### 2026-09-28 — define — attempt: define/ ready for the Define gate
- #53 (retire or redirect `brand-designer`) was recorded against REQ-034 in the Deferred table and in index Open question 4, and cited in the index header, index Non-goals and framing.md. No placeholders remain.
- The full-tier `define/` has 26 live requirements (21 Must, 5 Should) and 8 deferred rows (#46–#53). The anchor verdict is aligns, with anchor-update action `none`.

### 2026-09-28 — main — note: Define gate — adjust
- User feedback relayed to Define:
  - Design reads prior design knowledge only from the Diátaxis docs (explanation, reference, registry and ADRs), never from past session folders, because those corrupt context.
  - Design always applies SOLID, YAGNI and KISS, especially for software.
- **Output (relay 4, gate adjust):** done; all six define/ files updated

### 2026-09-28 — define — decision: Define-gate adjust — prior knowledge from docs only; design principles
- Design takes prior knowledge only from the project's Diátaxis docs (`docs/explanation`, `docs/reference`, `docs/registry` and ADRs), the code and the current session. It never reads past session folders, `archive/` included (REQ-035). With no project docs, it designs from the Define output and the code, and records that fact (REQ-036). This is distinct from REQ-024, which covers tools treating old artifacts the same.
- `plan`'s registry read (REQ-022) is consistent, because the registry is project documentation. #45 is recorded as a dependency, and REQ-036 covers repos where nothing is folded back.
- Design principles apply always: KISS and YAGNI on every element of every solution kind, and SOLID as well on software elements. Each significant choice and `DES-*` item gets a recorded principles check, with trade-offs resolved by the user (REQ-037). Anything no live `REQ-*` needs is rejected under YAGNI (REQ-038).
- New needs NEED-05 and NEED-06 and outcomes OUT-05 and OUT-06. The anchor verdict is unchanged: *aligns*, with update action `none`.

### 2026-09-28 — define — attempt: define/ ready for the Define gate (revision 2)
- There are 30 live requirements (25 Must, 5 Should) and 8 deferred rows (#46–#53). Quality coverage, assumptions, dependencies, framing interactions and all four diagrams are updated.
- New open question: whether the no-past-sessions rule should also apply to Define and the other phases.
- **Output (relay 5):** done; define/index.md, define/requirements.md updated

### 2026-09-28 — define — decision: OQ4 resolved — no-past-sessions rule stays Design-only; widening deferred to #54 (REQ-039)
- The user chose Design-only with a follow-up. The orchestrator created #54. Deferred row REQ-039 was added, with a matching Non-goals bullet.

### 2026-09-28 — main — milestone: ✅ Define complete
- The user approved `define/` (full tier): 30 live requirements (25 Must, 5 Should) and 9 deferred (#46–#54), needs NEED-01 to NEED-06 and outcomes OUT-01 to OUT-06. The anchor verdict is aligns, with action `none`, so no README write was needed.
- Next: the Design phase. This session's own Design uses the current template (constraint; REQ-024).

## Phase: Design

### 2026-09-28 — main — handoff: orchestrator → compass-labs:design (design from frozen define/)
- **Input:** design the solution for the 30 live REQs in the frozen `define/`, using the current `design.md` template (REQ-024 constraint). The open design choices named in `define/index.md` are Design's to settle with the user.
- **Output:** needs_input (11 design choices); design.md draft written

### 2026-09-28 — design — attempt: design.md draft written; 11 choices awaiting the user
- Drafted DES-001 to DES-017 covering all 30 live REQs, each with a result, a check and dependencies. It includes a proposed classification (plugin/tooling; scope checklist), a C4 component context view in Mermaid with delta styling, a delta list, a notation catalogue, the `plan` carry-over map (REQ-022), a principles check per DES item, a list of items rejected under YAGNI, and risks.
- Recommendations, pending the user:
  - ADRs recorded in the design, written to the registry at Close;
  - notation declared in `skills/design/reference/notations.md`;
  - delta as flowchart classDefs plus label suffix plus the delta table;
  - a `design/` folder with `design.md` as legacy, and a `check-design.sh` gate script;
  - no Bash, with a documented SVG route;
  - per-layer home `skills/{layer}/`;
  - no construct stubs, so nothing replaces `planned_in`;
  - `plan` deleted and its callers repointed;
  - stack defaults in `skills/design/reference/stack-defaults.md`;
  - Claude Design output as a link plus exported images in `assets/`.
- Prior knowledge came from the project docs, the ADRs and the code only; no past session folder was read.
- **Output (relay 1):** done; design.md finalised

### 2026-09-28 — design — decision: Design choices settled (Q1–Q11)
- The user confirmed primary kind plugin/tooling and its scope checklist (in: plugin/tooling, process/workflow; out: frontend, backend, database, infrastructure, visual UI design).
- ADRs: the design records options and links existing ADRs; new decisions are flagged, and Close writes them into docs/registry/decisions/ (ADR-004 for this session).
- Notation is declared in one catalogue, skills/design/reference/notations.md. The delta is a Mermaid flowchart with C4 abstractions, four classDefs, a [status] label suffix and the delta list table.
- The design artifact becomes a design/ folder, with design.md as its legacy layout, and a check-design.sh Design-gate script.
- Bash is granted to the Design agent, for rendering and render checks only (the user overrode the no-Bash recommendation). Mitigation for Bash writes bypassing the guard: a Bash rule in agents/design.md, plus the gate's existing git-status check before the commit.
- Per-layer home: skills/{layer}/, with nothing created now. No construct stubs, so nothing replaces planned_in.
- plan: the carry-over map is approved, and skills/plan/ is deleted with its callers repointed.
- Stack defaults live in skills/design/reference/stack-defaults.md.
- Claude Design's HTML zip is kept as-is at assets/ui-design.zip and linked, with one PNG screenshot per screen embedded in ui-handoff.md.
- The skill name stays `design`.

### 2026-09-28 — design — attempt: design.md ready for the Design gate
- DES-001 to DES-017 cover all 30 live REQs, with result, check and dependencies. The artifact has a context view, a delta list, options per decision, a principles check (two trade-offs for the user to resolve at the gate: DES-006 and DES-014) and risks. There are no open questions.

### 2026-10-04 — main — note: Design gate — adjust: no quality standard per notation
- The user raised a gap at the Design gate: the design says which notation each visual uses (REQ-013, `notations.md`) but not what makes a diagram in that notation good. There is no reference material or checklist for a good ERD or a good BPMN workflow, and no step checks a visual against one. Define has this through the `requirements` skill's ISO/IEC/IEEE 29148 rules; Design has no equivalent.
- No live REQ asks for notation quality rules, so under REQ-038 Design can't add them alone. Asking the user how to scope it.

### 2026-10-04 — main — decision: notation quality standards deferred to #55
- The user chose a follow-up issue over reopening Define or stretching REQ-013. Created #55, linked to #27 and this session.
- Agreed shape for #55: for each notation, cite an authoritative source (for example c4model.com, OMG BPMN 2.0.2 with Silver's Method and Style, crow's-foot conventions and normal forms) and write a short pass/fail checklist that Design records per visual.
- design.md is unchanged; the Design gate continues.
