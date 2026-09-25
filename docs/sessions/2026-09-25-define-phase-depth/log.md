---
session: 2026-09-25-define-phase-depth
type: feature
issue: 23
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
active_agent: compass-labs:design
next_step: "Design revises parked design.md against REQ-001..046"
---
# Session Log: Define phase depth — problem framing, per-type standards, project anchoring (#23)

> Format: D2. Only the orchestrator writes this file. Entries are append-only.
> Artifacts: [`requirements.md`](requirements.md) · [`design.md`](design.md) · [`tasks.md`](tasks.md) · [`verification.md`](verification.md) · [`release.md`](release.md)

## Open items

- #40: Bugfix framing depth, deferred until the Bugfix workflow (#24) exists.
- design.md (DES-001..016 plus the visual overview) is being revised against REQ-023..046.
- #39: refine the Design phase to use visual, type-specific artifacts with a clear new/changed/deprecated view. Deferred, related to #27.
- #38: `init` should set up the project anchor (vision and mission) when a project is created. Blocked by this session's anchor contract.
- #37: the session skill's new-session flow should create a branch before its first commit/push. Deferred, out of scope here.

## Key decisions

- **2026-09-25**: ✅ Define complete (re-approved) — REQ-001..046 (REQ-012 dropped): framing, anchor contract, Feature-depth problem statement + requirements + visuals, bounded methods research
- **2026-09-25**: REQ-014 amended: Bugfix verdict may be "deferred to #40"; REQ-041 stays outcome → REQ (no new REQ)
- **2026-09-25**: Traceability diagram at Define stays outcome → REQ (DES links via #39, VER links via #29); REQ-014 allows "deferred to #40" as a Bugfix verdict
- **2026-09-25**: Feature-depth outcomes: problem statement = SCQ context, job-story need, observed/assumed evidence, impact + why now, measurable outcome, appetite + no-gos (templates offered, not mandated); requirements add ISO 25010:2023 coverage, NFR response measures, MoSCoW, upward trace, assumptions/dependencies, example-based criteria, worked example; tiered Mermaid visuals; Bugfix depth deferred to #40
- **2026-09-25**: Define reopened (milestone rolled back to none): REQs don't demand concrete Feature-depth outcomes for the problem statement and requirements standards; design.md parked as draft until Define is re-approved
- **2026-09-25**: Design-phase refinement (visual, type-specific artifacts — BPMN 2.0 for process designs — with explicit new/changed/deprecated delta) deferred to #39; this session gets a BPMN 2.0 visual of its own design before the gate
- **2026-09-25**: design.md drafted to the four leans (DES-001..016); D6 proposed: pre-change sessions grandfathered (gate check a3 only when a Framing section exists) — pending user confirmation at gate
- **2026-09-25**: Design choices: orchestrator applies anchor writes + Define-gate check; anchor = marked `## Project anchor` section in root README; new `framing` skill + per-type `framing` block in workflow JSON; `problem-statement` + `requirements` skills with `types/*.md` and per-section `reference/methods.md`, ADR-003 for the whole
- **2026-09-25**: ✅ Define complete — REQ-001..022 approved (REQ-012 dropped); framing, per-type standards, anchor contract, #32 research bounded
- **2026-09-25**: Skip tier skips every framing check, including anchor verdict and anchor creation (REQs unchanged)
- **2026-09-25**: Anchor contract: one labelled authoritative statement in persistent project docs; vision + mission + scope required, non-goals optional; create/complete once with approval (REQ-018..022); REQ-012 struck
- **2026-09-25**: Project anchor split: this session defines the anchor contract (vision + mission) and framing creates it once if missing (supersedes the per-session ask fallback); init establishing it at project creation deferred to #38
- **2026-09-25**: Framing answers folded into requirements.md: "extends" verdict applied before the framing milestone; Close fold-back unchanged (non-goal); user confirms each session's depth tier
- **2026-09-25**: Session skill should branch before its first commit/push; deferred to #37
- **2026-09-25**: Framing open questions settled: full refresh of compass-labs README + solution-design in this session; owed anchor update made at framing time; no-anchor fallback = ask user for 1–2 sentence purpose, recorded in session; framing effort scales with size of work (in scope)
- **2026-09-25**: Framing standards are one skill per artifact section (problem statement, requirements), with standards picked by session type
- **2026-09-25**: Project anchor = README + docs/explanation/solution-design.md; registry/ADRs are overlap/conflict context only; "extends" owes an anchor update
- **2026-09-25**: Generalise the problem-framing step (not a Define phase) across session types; Feature + Bugfix concrete here, Research gets an extension point only (#25)
- **2026-09-25**: Session absorbs #26 (Define standard) and #32 (requirements methodology research); plan skill rework is out of scope
- **2026-09-25**: Session opened on existing issue #23, broadened from "plan skill Q0 problem framing" to the depth of the Define phase as a whole (three threads below)

---

## Phase: Define

### 2026-09-25 — main — decision: session opened on #23 with broadened scope
- The user picked up #23 and said it needs updating now that the session lifecycle (#22) has shipped. The Define phase is currently thin. They raised three threads:
  1. **Broaden beyond SDLC.** Define was framed around software delivery, but sessions now cover other activities (for example Research, per #24/#25). How should Define generalise across session types?
  2. **Get specific per variation.** Start with SDLC work (feature, bugfix). What makes a good problem statement, and what makes good requirements? Break down the relevant standards and give each one its own skill.
  3. **Anchor to the project.** Every feature definition should be anchored to the repository as a whole. There's a core README, so when does a feature align with the project's existing framing, and when does it extend it?
- #23's original research (XY problem, SCQ/Minto, Genchi Genbutsu symptom-vs-cause split, 5 Whys caveats, JTBD, PR-FAQ) and its Q0 full/short/skip proposal carry forward as input material, not as an agreed solution.

### 2026-09-25 — main — handoff: orchestrator → compass-labs:define (agree problem statement for three threads)
- **Input:** session `docs/sessions/2026-09-25-define-phase-depth/`, phase define; task: turn the three threads plus #23's original research into an agreed problem statement, scope/non-goals and constraints first (problem before solution), then REQ-* requirements. Issue #23 body is at hand for the original research.
- **Output:** needs_input (4 framing questions); files_changed: none

### 2026-09-25 — compass-labs:define — note: current-state review before problem framing
- Read define.md, the requirements skill, the requirements template, session SKILL.md, feature.json, plan SKILL.md, README, docs/explanation (solution-design, session, plan), docs/registry/index.md, and the archived session's follow-up table.
- Findings: Define has no framing or discovery guidance and doesn't read project context. The requirements skill covers only the REQ table. Artifacts are Feature-only, and the planned Bugfix workflow (#24) has no Define phase. The README and solution-design are stale ("Systematic Dev Kit", full-stack framing). Plan's discovery overlaps Define and its layer design overlaps Design. #26 (Define standard) and #32 (requirements research) overlap this session's scope.
- Asked the user 4 framing questions (issue absorption and plan, generalisation unit and types, project anchor, standards granularity) before drafting a problem statement.

### 2026-09-25 — main — decision: framing answers (scope, generalisation, anchor, granularity)
- **Scope:** absorb #26 and #32. The plan skill isn't reworked here.
- **Generalisation:** the thing that generalises is the problem-framing step, not a Define phase. Feature and Bugfix are done concretely in this session. Research gets an extension point only, with the rest deferred to #25. No other session types for now.
- **Anchor:** README plus docs/explanation/solution-design.md. The registry and ADRs are checked only for overlap or conflict. An "extends" verdict means an anchor update is owed. A repo with no anchor gets a defined fallback.
- **Granularity:** one skill per artifact section (problem statement, requirements), each picking its standards by session type.

### 2026-09-25 — main — handoff: orchestrator → compass-labs:define (draft problem framing from answers)
- **Input:** the four answers above. Task: draft the Problem statement, Scope, Non-goals, Constraints and Open questions in requirements.md. No REQ rows until the framing is agreed.
- **Output:** done (framing draft for review); files_changed: requirements.md

### 2026-09-25 — compass-labs:define — attempt: framing draft written for review
- Filled in Problem statement, Scope, Non-goals, Constraints and Open questions in requirements.md from the user's answers: absorb #26 and #32; generalise the framing step, not a Define phase; Feature and Bugfix concrete, Research as an extension point only; anchor is the README plus solution-design, with the registry and ADRs checked only for overlap or conflict; one skill per artifact section.
- Fixed #32's boundary in Scope item 6 and Constraints: a named candidate list with at most 3 additions per section, an adopt/adapt/reject verdict for each of Feature and Bugfix, and the research is done when every candidate has one.
- No REQ rows yet. 4 open questions await the user: fixing compass-labs' own stale anchor docs, when an owed anchor update is made, the no-anchor fallback, and scaling framing effort to the size of the work.

### 2026-09-25 — main — note: session moved to branch feat/23-define-phase-depth
- The user asked for session work to go on a new branch, not `main`. The opening commit `d38c99c` had already been pushed to `origin/main`, and it's now also part of the branch's history. Whether to revert it on `main` is still open (see Open items). Local `main` has been reset to `origin/main`.

### 2026-09-25 — main — decision: framing open questions settled
- **Stale anchor docs:** refresh compass-labs' README and `solution-design.md` fully in this session (not the agent's suggested middle path).
- **When an owed anchor update happens:** at framing time, before anything is built. This isn't the agent's lean either; nothing waits for Close.
- **No-anchor fallback:** the framing step asks the user for a 1–2 sentence project purpose and records it in the session's own artifact. It never creates project docs.
- **Scaling:** how much framing is done scales with the size of the work (full, short or skip), and this is in scope.

### 2026-09-25 — main — handoff: orchestrator → compass-labs:define (fold in open-question answers, draft REQ rows)
- **Input:** the four answers above. Task: update Scope, Non-goals and Open questions to match, then draft REQ rows in EARS form with Given/When/Then criteria.
- **Output:** done (REQ-001 to REQ-017, ready for Define milestone review); files_changed: requirements.md

### 2026-09-25 — main — note: reverted session-open commit on main
- The user asked for the revert to follow best practice. I added `912634c` to `origin/main` with `git revert` (no history rewrite, no force-push), working in a temporary worktree so this branch's working tree wasn't touched.
- Still to do: the branch contains `d38c99c`, and `main` now reverts it. Before the first push, merge `origin/main` into the branch and resolve the modify/delete conflict by keeping the branch's files.

### 2026-09-25 — main — decision: defer session-skill branching fix to #37
- The session skill's New session flow commits and pushes the opening commit without creating a branch, which is how `d38c99c` reached `main`. Fixing the skill is outside this session's scope, so I opened #37 to track it.

### 2026-09-25 — compass-labs:define — decision: framing answers folded into requirements.md
- A full refresh of README.md and solution-design.md is in scope (Scope item 8), done in Implement.
- An "extends" verdict is settled during framing: the anchor update is agreed with the user and applied before the framing milestone is approved. Close's fold-back is unchanged, which is now a non-goal.
- No-anchor fallback: ask for a 1–2 sentence purpose, record it in the session artifact, and never create project docs.
- Depth tiers (full, short, skip) are in scope. The user confirms each session's tier.

### 2026-09-25 — compass-labs:define — attempt: REQ-001 to REQ-017 drafted for Define milestone review
- 17 EARS requirements, each with one Given/When/Then, covering Scope items 1–8, including the #32 research (REQ-014, REQ-015) and the anchor refresh (REQ-016, REQ-017). Each was checked against the ISO 29148 quality checklist.
- For the user to confirm at the gate: checks don't run at skip tier; REQ-011 leaves who applies the anchor update to Design; the refresh needs the user to approve a new purpose statement.

### 2026-09-25 — main — decision: project anchor is established once, not asked per session; init work split to #38
- The user interrupted the Define gate. Compass is meant to be a verbose, general workflow for any kind of work, not only full-stack development. A project's vision and mission should be anchored once, during init, and created if they don't exist, so the user doesn't have to restate them every session.
- Split, as the user chose. **This session** defines the anchor contract: what the vision and mission must state, and where the anchor lives. The framing step reads the anchor, and if it's missing, framing creates it once with the user's approval and commits it. This **supersedes** the earlier fallback of asking every session and never creating project docs (REQ-012 as drafted). The compass-labs README and solution-design refresh (REQ-016/017) is the first anchor written to the contract. **Deferred to #38:** `init` sets up the anchor at project creation (greenfield and brownfield-migrate). Related to #19.

### 2026-09-25 — main — handoff: orchestrator → compass-labs:define (revise anchor requirements for the split)
- **Input:** the decision above. Task: strike REQ-012 through, add requirements for the anchor contract and for create-if-missing, align REQ-016/017 to the contract, update Scope, Non-goals (#38) and Constraints. Also raise the skip-tier question (whether checks are skipped at skip tier) as an open question.
- **Output:** done after one restart. A rate limit interrupted the first run, and I resumed the same agent with SendMessage. files_changed: requirements.md

### 2026-09-25 — compass-labs:define — decision: project anchoring reframed as an anchor contract, created once
- The user reframed anchoring. A project's vision and mission are recorded once, in an anchor that meets a contract, and created if they don't exist, so they're never restated each session. Compass is a general workflow, not only for full-stack development.
- Anchor contract: one authoritative, labelled statement in the project's persistent docs. Vision, mission and scope are required; non-goals are optional and checked when present. The exact location and layout are left to Design (REQ-018, REQ-019).
- Create or complete if missing, once, with the user's approval, as persistent project docs (REQ-020, REQ-021). Reuse without restating (REQ-022). REQ-012's per-session fallback is dropped (struck through).
- compass-labs' README and solution-design refresh becomes the first anchor written to the contract (REQ-016, REQ-017).
- Anchor setup in `init` for new and existing projects is deferred to #38 (related #19).

### 2026-09-25 — compass-labs:define — attempt: requirements.md revised and ready for the Define milestone gate
- Updated Problem statement, Scope item 6 and item 8, Non-goals (#38) and Constraints (general-workflow constraint added, "never create project docs" wording removed). Added REQ-018 to REQ-022, revised REQ-010, 013, 016 and 017, and struck through REQ-012.
- One open question for the user: whether skip tier skips all framing checks, including the anchor ones. Lean: yes.

### 2026-09-25 — main — handoff: orchestrator → compass-labs:define (resolve skip-tier question, mark approved)
- **Input:** the user chose "skip everything" at skip tier and approved the Define milestone. Task: mark the open question resolved and set the status line to Approved. Change nothing else.
- **Output:** done; files_changed: requirements.md

### 2026-09-25 — compass-labs:define — decision: skip tier skips all framing checks, including anchor checks
- The user took the lean: at skip tier, framing skips every check, including the aligns/extends verdict and anchor creation or completion (REQ-020, REQ-021). A missing anchor is created at the next full- or short-tier session.
- The REQs already say this (REQ-005, 006, 010, 013, 020 and 021 run only at full or short tier), so they're unchanged. The open question is marked resolved in requirements.md.

### 2026-09-25 — compass-labs:define — note: requirements.md marked approved, ready to freeze
- Status line set to "Approved (Define complete 2026-09-25)" on the user's approval relayed by the orchestrator. Open questions: all resolved.
- Final set: REQ-001 to REQ-022, with REQ-012 struck through (replaced by REQ-020 and REQ-021). For Design to pick up: who writes the anchor to project docs (REQ-011, 020, 021), since the phase-agent contract limits Define to its own artifact.

### 2026-09-25 — main — milestone: ✅ Define complete
- The user approved requirements.md: REQ-001 to REQ-022, with REQ-012 struck through. Open questions: all resolved.
- Carried into Design: who writes anchor changes to project docs (REQ-011, 020, 021) under the phase-agent contract; the user must approve compass-labs' vision and mission wording during Implement (REQ-016).

## Phase: Design

### 2026-09-25 — main — note: Define milestone synced; branch reconciled with main
- Merged `origin/main` into the branch (`39ad3dd`), keeping the session files over main's revert, then pushed `feat/23-define-phase-depth`. #23 moved to `phase:design` with the milestone comment.
- Rewrote #23's title and body to the agreed scope, with the original Q0 proposal kept in a collapsed section. Commented on #26 and #32 that they are absorbed into #23.

### 2026-09-25 — main — handoff: orchestrator → compass-labs:design (DES-* for REQ-001..022)
- **Input:** requirements.md approved (REQ-001 to REQ-022, REQ-012 dropped). Carried questions: who writes anchor changes to project docs (REQ-011, 020, 021) under the phase-agent contract, and where the anchor lives (REQ-018 leaves the layout to Design). The user prefers problem framing before solutions and wants options with leans, not a finished design dropped on them.
- **Output:** needs_input (4 design questions); files_changed: none

### 2026-09-25 — compass-labs:design — note: current-state review; four design decisions put to the user
- Read requirements.md (REQ-001 to REQ-022, REQ-012 struck), log.md, the design and requirements templates, the define, design and close agents, the requirements and session skills, the phase-agent contract, session-guard.sh, feature.json, README.md, solution-design.md, init SKILL.md and the ADR index.
- Findings: the guard hook only enforces inside `docs/sessions/`, so writes to project docs are limited by the contract alone, and Close already has a documented exception for writing `docs/`. REQ-011 needs a Define-gate check like Deploy's step a2. The anchor needs a location that can be detected mechanically for REQ-018 and REQ-022. The next ADR number is 003.
- Asked 4 questions, each with a lean: who writes the anchor (lean: the orchestrator, plus a gate check); the anchor's location and form (lean: a README section with markers); framing's relation to Define and other types (lean: a `framing` skill plus a per-type `framing` block in the workflow JSON); skill layout and research record (lean: `problem-statement` plus `requirements` skills with per-type files, and a methods record per section).

### 2026-09-25 — main — decision: four design choices (all agent leans)
- **Anchor writes:** Define drafts the anchor text with the user and records it in requirements.md. The orchestrator writes it into the anchor in the same commit as the decision. A Define-gate check, like Deploy's step a2, refuses the milestone while an agreed update is missing. The phase-agent contract is unchanged.
- **Anchor home:** a `## Project anchor` section in the root README (Vision, Mission, Scope, optional Non-goals) between `<!-- compass:anchor -->` markers. Other docs link to it.
- **Framing packaging:** a new `framing` skill holds the phase-agnostic procedure. Each `workflows/<type>.json` gets a `framing` block, and requirements.md gets a Framing section.
- **Skills layout:** a new `problem-statement` skill, and the existing `requirements` skill. Each has `types/feature.md` and `types/bugfix.md`, loaded only when needed, and a `reference/methods.md` holding its method verdicts. ADR-003 records the overall decision.

### 2026-09-25 — main — handoff: orchestrator → compass-labs:design (relay answers; draft design.md)
- **Input:** all four leans accepted. Draft design.md with DES-* components covering every REQ.
- **Output:** done (DES-001..016 for Design milestone review); files_changed: design.md

### 2026-09-25 — compass-labs:design — decision: design leans adopted (anchor writes, anchor location, framing skill, skill layout)
- The user accepted all four leans. Q1: the orchestrator applies anchor writes, and the Define gate gets check a3, like Deploy's a2. Q2: the anchor is a `## Project anchor` section in the root README, between `<!-- compass:anchor -->` markers. Q3: a new `framing` skill, a per-type `framing` block in the workflow JSON, and a Framing section in the requirements template. Q4: `problem-statement` and `requirements` skills, each with `types/feature.md`, `types/bugfix.md` and `reference/methods.md`. ADR-003 covers the design as a whole.

### 2026-09-25 — compass-labs:design — attempt: design.md drafted for Design milestone review
- DES-001 to DES-016 cover REQ-001 to REQ-022; REQ-012 is struck and needs none. The #32 methods research is carried out in Implement (DES-013), before the per-type standards are finalised. ADR-003 is written in Implement (DES-016).
- Decisions D1 to D6. D6 (the agent's addition) grandfathers sessions created before this change: the Framing section and the gate check apply only when the Framing section is present.
- Risks cover breaking the anchor markers, preload load and gaps, research scope creep, traceability after the restructure, the new `feature.json` key, and the anchor write overwriting the user's wording.

### 2026-09-25 — main — decision: visual review before the Design gate; Design-phase refinement deferred to #39
- The user interrupted the Design gate. design.md is text-only and hard to review: it doesn't show how the design fits the SDLC or session process, or the project as a whole, and it doesn't separate what is new, changed or deprecated.
- **For this session:** produce a visual of this design before the gate. That means a BPMN 2.0 process model, with the source kept in the session's `assets/`, showing the session lifecycle with the Define/framing flow expanded and each element marked new, changed or unchanged, plus a project-context view.
- **Deferred to #39:** refining the Design phase itself, with visual artifacts chosen by the kind of design (BPMN 2.0 for process designs; architecture and infrastructure views for application designs; front-end design to be discussed separately) and an explicit current → new delta. Related to #27.

### 2026-09-25 — main — handoff: orchestrator → compass-labs:design (add Mermaid visual overview)
- **Input:** the user asked for Mermaid diagrams (not BPMN XML) viewable in Markdown. Task: add a `## Visual overview` section to design.md, copied verbatim from the orchestrator's draft: three diagrams (lifecycle, Define phase expanded, project map) plus a delta table. The first attempt was blocked because I hadn't saved the draft yet; it ran again once the draft was saved.
- **Output:** done; files_changed: design.md

### 2026-09-25 — compass-labs:design — attempt: visual overview added to design.md for the Design gate
- The user found the text-only design hard to review. Added a `## Visual overview` section after Approach, copied verbatim from the orchestrator's draft: a colour legend, three Mermaid diagrams (lifecycle, Define phase expanded, project map) and a table of what's new, changed, superseded and unchanged, mapped to DES IDs. The diagrams are BPMN-style, not strict BPMN 2.0; which notation to use is tracked in #39. No other part of design.md changed.

### 2026-09-25 — main — decision: Define reopened for Feature-depth requirements
- At the Design gate, the user asked whether the Define phase's depth for Feature work had actually improved: which frameworks, and what better problem statements and requirements. The design was thorough on framing mechanics but thin on the standards' content. For DES-011, the problem statement had only an expected shape, with methods deferred to research in Implement. For DES-012, Feature requirements were "the current EARS standard", a file move with no added depth.
- I recommended moving the #32 research into Design. The user chose to go back to Define instead: the requirements themselves don't ask for enough depth, so requirements for specific Feature-depth outcomes come first.
- Frontmatter rolled back: `milestone: none`, `phase: define`, so requirements.md can be edited again. design.md stays as a draft, to be revised after Define is re-approved. #23 moves back to `phase:define`.

## Phase: Define (reopened)

### 2026-09-25 — main — handoff: orchestrator → compass-labs:define (Feature-depth outcome requirements)
- **Input:** Define reopened. Task: find out with the user what "deeper Define for Feature work" must achieve for the problem-statement and requirements standards, and add outcome-level REQs for it. Options with leans, not solutions. Existing REQ-001..022 stay unless the user changes them.
- **Output:** needs_input (4 Feature-depth questions); files_changed: requirements.md (status line only)

### 2026-09-25 — compass-labs:define — note: Define reopened to deepen the Feature definition
- requirements.md status set back to "Draft (reopened 2026-09-25)". REQ-001 to REQ-022 are unchanged so far.
- Gap: REQ-007 and REQ-008 only require that a standard "defines content and methods". They set no depth a Feature problem statement or Feature requirements must reach, so the draft design only reshuffled the existing EARS standard.
- Asked the user 4 questions: required Feature problem-statement elements by tier (lean: need and who, evidence, impact/why now, measurable success outcomes; no mandated framework); requirements additions (lean: ISO 25010 coverage with explicit N/A, priority, upward traceability, assumptions and dependencies, worked example); Bugfix now or later (lean: Feature now, Bugfix as a follow-up); relation to the #32 research (lean: Define fixes the outcomes, the research only picks methods).

### 2026-09-25 — main — note: user asked for methods research before answering
- The user asked the orchestrator to research methodologies for Feature definition now: problem statement, functional requirements, non-functional requirements, acceptance criteria, and visual representations beyond tables. The Define agent's 4 questions are held until the research is presented.

### 2026-09-25 — main — note: methods research presented (problem statement, FR, NFR, acceptance criteria, visuals)
- Surveyed methods for each part of a Feature definition and presented a verdict lean for each.
  - Problem statement: SCQ/Minto, JTBD job stories, the XY check, observed vs assumed evidence, Impact Mapping, the Opportunity Solution Tree, and Shape Up's appetite and no-gos.
  - Functional requirements: EARS (keep), user and job stories, story mapping.
  - Non-functional requirements: an ISO/IEC 25010:2023 checklist (9 characteristics; the Define agent's list used the older 2011 names), SEI quality-attribute scenarios, and Planguage.
  - Acceptance criteria: Given/When/Then (keep) plus Example Mapping. Prioritisation: MoSCoW per requirement.
  - Visuals, each checked for Mermaid support: impact map and OST (mindmap), context and as-is/to-be flows (flowchart), journey (journey), quality utility tree (mindmap), priority quadrant (quadrantChart), traceability (requirementDiagram).
- The research feeds the Define agent's 4 Feature-depth questions, which go to the user next.

### 2026-09-25 — main — decision: Feature-depth outcomes agreed (all research-informed leans)
- **Feature problem statement, full tier:** context (SCQ), the need and who has it (job story), evidence tagged observed or assumed with sources, impact and why now, a measurable success outcome, and appetite plus no-gos. The standard mandates the content; frameworks are offered as templates. Short tier keeps the need and who, the evidence, and the success outcome.
- **Feature requirements, beyond EARS, Given/When/Then and 29148, at full tier:**
  - ISO/IEC 25010:2023 coverage: each of the 9 characteristics either gets a requirement or is marked not applicable with a reason.
  - NFRs carry a response measure, with a Tolerable/Goal pair when numeric.
  - MoSCoW priority on every requirement.
  - Upward trace: each requirement names the outcome it serves, and every outcome is served.
  - Assumptions and dependencies.
  - Acceptance criteria built from worked examples, with unknowns sent to Open questions.
  - A worked example in the standard.
  - Short tier keeps priority and the trace to an outcome. REQ-009 (the traceability parser) still binds.
- **Visuals, tiered:** full tier requires an impact map, a context diagram and a traceability diagram (outcome → requirement → design → verification), plus an as-is/to-be flow when a process changes. Others are optional. All in Mermaid. Short and skip tiers need none.
- **Scope:** Feature now; Bugfix depth goes to #40. The research becomes the #32 verdict record, and REQs fix the outcomes the methods serve.
- **Research verdicts (the #32 record, carried into Implement):**
  - Problem statement: adopt XY, SCQ, job story and observed/assumed evidence; adapt Impact Mapping, the OST and Shape Up appetite/no-gos; reject 5 Whys (it belongs to Bugfix) and PR-FAQ.
  - Functional requirements: adopt EARS (5 patterns) and 29148; adapt stories and story mapping; reject use cases.
  - NFRs: adopt ISO 25010:2023; adapt SEI QA scenarios and Planguage; reject FURPS+.
  - Acceptance criteria: adopt GWT; adapt Example Mapping and Specification by Example.
  - Priority: adopt MoSCoW; reject Kano, RICE and WSJF at requirement level.

### 2026-09-25 — main — handoff: orchestrator → compass-labs:define (write Feature-depth REQs)
- **Input:** the four Feature-depth answers plus the research verdicts (the decision above). Task: add REQ-023 onward, tighten REQ-007 and REQ-008, update Scope, Non-goals and Constraints.
- **Output:** done (REQ-023..046; REQ-007 and 008 tightened); files_changed: requirements.md

### 2026-09-25 — compass-labs:define — attempt: Feature-depth outcome REQs drafted (REQ-023 to REQ-046)
- Added tier-aware outcome REQs from the agreed Feature-depth decision:
  - problem-statement content (REQ-023–029)
  - requirements content: ISO 25010:2023 coverage, NFR response measures, MoSCoW, upward trace, assumptions and dependencies, example-based criteria, worked example (REQ-030–038)
  - Mermaid visuals (REQ-039–045)
  - research verdicts naming the outcome REQ they serve (REQ-046)
- Tightened REQ-007 and REQ-008 to require the Feature content from REQ-023–029 and REQ-030–038, keeping their IDs and intent. REQ-014 and REQ-015 are unchanged.
- Scope: skip-tier answer recorded; Bugfix depth stays at REQ-006–008 (#40); item 7's candidate list expanded to every method the research assessed, so the cap of three additions doesn't count them; new item 9 summarises Feature depth. Non-goals: #40, #39. Constraints: templates not mandates, Mermaid renderability, REQ-009 covers priority and trace.
- Status: "Draft (ready for Define milestone re-review)". One open question for the gate: who extends the traceability diagram to DES and VER (lean: #39 and #29; REQ-041 stays outcome → REQ). Flagged that REQ-014 still owes Bugfix verdicts for every candidate.

### 2026-09-25 — main — decision: gate answers on traceability chain and Bugfix verdicts
- REQ-041 stays outcome → REQ. Extending the diagram with DES links belongs to Design (#39) and VER links to Test (#29).
- REQ-014 changes by one line: a Bugfix verdict may be "deferred to #40".
- The user approved the Define milestone re-review with these folded in.

### 2026-09-25 — main — handoff: orchestrator → compass-labs:define (fold in gate answers, mark approved)
- **Input:** the two answers above, and Define approved. Task: amend REQ-014, resolve the open questions, set the status to Approved.
- **Output:** done; files_changed: requirements.md

### 2026-09-25 — compass-labs:define — decision: gate answers on traceability diagram scope and Bugfix verdicts
- REQ-041 stays at outcome → REQ. Design adds the DES links (#39) and Test adds the VER links (#29). No new REQ.
- REQ-014 accepts "deferred to #40" as a Bugfix verdict. Feature verdicts are still required for every candidate, and a deferral needs no rationale or applicability condition.

### 2026-09-25 — compass-labs:define — note: requirements.md marked re-approved, ready to freeze
- Status line set to "Approved (Define complete 2026-09-25, re-approved after reopen)" on the user's approval, relayed by the orchestrator. Open questions: all resolved.
- Final set: REQ-001 to REQ-046, with REQ-012 struck through (replaced by REQ-020 and REQ-021).

### 2026-09-25 — main — milestone: ✅ Define complete (re-approved after reopen)
- The user re-approved requirements.md: REQ-001 to REQ-046, with REQ-012 struck through. Open questions: all resolved.
- New since the first approval: tier-aware Feature-depth outcomes for the problem statement (REQ-023–029), requirements (REQ-030–038) and Mermaid visuals (REQ-039–045), plus verdicts that name the outcome they serve (REQ-046).

## Phase: Design (resumed)

### 2026-09-25 — main — handoff: orchestrator → compass-labs:design (revise design.md for REQ-023..046)
- **Input:** Define re-approved. Task: revise the parked design.md so DES items cover REQ-023..046 with concrete standard content (the problem-statement and requirements type files, the methods record with research verdicts, the Mermaid visual requirements), extend the visual overview, and keep all four earlier design choices. The research verdicts are in the Define (reopened) decision entry.
