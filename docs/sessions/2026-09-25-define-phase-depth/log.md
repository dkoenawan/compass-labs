---
session: 2026-09-25-define-phase-depth
type: feature
issue: 23
phase: close
status: archived
# milestone: the PHASE KEY of the last completed milestone, not a display
# label. Allowed values (feature workflow): none | define | design |
# implement | test | deploy | close. "none" until the first milestone
# (Define complete) is reached. The guard hook (D7) uses this key, plus
# each phase's `order` in workflows/<type>.json, to decide which
# artifacts are frozen. Display labels (e.g. "Define complete") live only
# in workflows/<type>.json's `milestone` field, for GitHub comments.
milestone: close
active_agent: main
next_step: "None. Session archived. The user merges PR #44, then runs claude plugin tag --push and claude plugin update on main"
---
# Session Log: Define phase depth — problem framing, per-type standards, project anchoring (#23)

> Format: D2. Only the orchestrator writes this file. Entries are append-only.
> Artifacts: [`requirements.md`](requirements.md) · [`design.md`](design.md) · [`tasks.md`](tasks.md) · [`verification.md`](verification.md) · [`release.md`](release.md)

## Open items

- #40: Bugfix framing depth, deferred until the Bugfix workflow (#24) exists.
- #39: refine the Design phase to use visual, type-specific artifacts with a clear new/changed/deprecated view. Deferred, related to #27.
- #38: `init` should set up the project anchor (vision and mission) when a project is created. Blocked by this session's anchor contract.
- #41: doc-maintainer's session fold-back step (2.S1) still expects the old plan-format session. Deferred; #23 only updates `close-foldback.md`.
- #42: use the Compass artifact repository as a bench test and eval for the session standards. Deferred to a separate conversation.
- #43: Consulting engagement session type, listed as planned in the project anchor's scope.
- #37: the session skill's new-session flow should create a branch before its first commit/push. Deferred, out of scope here.

## Key decisions

- **2026-09-28**: ✅ Session closed — fold-back into the as-built docs (define/ folder, framing domain, 2 registry patterns); PR #44 left for the user to merge; #23 closed
- **2026-09-28**: Task 21 (DES-022) ticked in the frozen tasks.md; the Close fold-back covers the `define/` folder in the as-built docs
- **2026-09-27**: ✅ Deploy complete — v1.2.0 bumped on branch, PR #44 open to main, release.md completeness shows no gaps; tag and plugin update after the merge
- **2026-09-27**: ✅ Test complete — 37 VER rows, all 45 live REQs pass at 58f91dd after the worked-example fixes; tests 15/15; check-traceability exit 0
- **2026-09-27**: ✅ Implement complete — tasks 1–20 done (DES-001..021, DES-023), task 21 (DES-022) deferred to Close; tests 15/15 green
- **2026-09-27**: compass-labs project anchor approved and written to README (vision: AI-assisted delivery work across software, research and consulting, based on common enterprise frameworks); Consulting session type → #43
- **2026-09-27**: ✅ Design complete — DES-001..023, D1–D14: framing skill + anchor contract, Feature-depth standards, `define/` folder (main doc + sub-docs by tier), Close fold-back into Diátaxis, defaults not rigid rules
- **2026-09-27**: Design gate answers: D6 = no bulk migration of past sessions; D8 "later" Won'ts go to a Deferred table with a required issue; D10 traceability form chosen per case (requirementDiagram or flowchart); no-rigidity principle; eval repo → #42
- **2026-09-27**: Close fold-back mapping for define/ docs: still-true content → Diátaxis docs (explanation/reference), the history of how we got there stays in the archive; no session IDs in as-built docs; doc-maintainer S1 → #41
- **2026-09-27**: Folder layout is a Design decision (D12–D13), not a Define reopen; requirements unchanged
- **2026-09-27**: Define output becomes a `define/` folder (index.md main doc + focused sub-docs); Design gains an artifact view with this session as the before/after
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
- **Output:** done (DES-001..018; D6–D11 proposed); files_changed: design.md

### 2026-09-25 — compass-labs:design — attempt: design.md revised for REQ-023..046 (Feature depth made concrete)
- DES-011 and DES-012 now give the actual structure of each Feature type file: an element × tier table naming the required content, the optional template with its verdict, and the REQ it satisfies. The agent read `check-traceability.sh` to confirm that the Priority and Serves columns and the new tables don't affect it: it parses only the first column, matching `| REQ-nnn`, and struck rows are skipped.
- Added DES-017 (diagram catalogue: 4 required at full tier, 6 optional, Mermaid type and checks, rendering rules) and DES-018 (worked full-tier example, which doubles as the REQ-009 test fixture). DES-008 now has a section × tier template table. DES-013 now has a starting verdict table with a Serves column (REQ-046) and "deferred to #40" as a Bugfix option.
- Added current-vs-new comparison tables for both standards. Visual overview: a full-tier step added to diagram 2, labels updated in diagram 3, a new tier mindmap (diagram 4), and the delta table extended.
- Coverage: REQ-001 to REQ-046 (REQ-012 struck). For the gate: D6 to D11 are proposals; D10 (traceability as a flowchart, not a requirementDiagram) departs from the research lean; the Feature verdict for symptom-vs-cause is missing from the recorded verdicts (adopt proposed); the Bugfix verdict column is a proposal.

### 2026-09-27 — main — decision: Define output becomes a `define/` folder; Design gains an artifact view
- **Gap raised by the user at the Design gate:** design.md never shows the actual artifacts: which files exist today, which are new or changed, and how a real session's Define output differs before and after. This session should be the example.
- **New principle:** don't overcrowd the Define document. Define's output may be a folder with one main doc linking to focused sub-docs. (Called the "main doc", not "anchor doc", to avoid clashing with the project anchor.)
- **Layout chosen:** everything in `define/`: `index.md` (the main doc), `requirements.md` (the REQ table), `framing.md`, `problem.md`, `quality.md`, `diagrams.md`. Sub-docs exist only when the confirmed tier requires them. Rejected: keeping `requirements.md` at the root as the main doc with a `define/` folder (fewer changes), and flat sibling files.
- **Consequences:** Define is amended: the "session artifact" glossary line becomes the folder, a new REQ covers the layout principle, and REQ-009's path moves to `define/requirements.md`. Design is revised: the artifact view, `check-traceability.sh` reading `define/requirements.md` with a root fallback for pre-change sessions (D6), the `feature.json` allowlist and artifact, the guard hook matching by folder prefix, and links in the downstream agents and templates. `design.md` stays flat. Whether the other phases get folders is #39's question.

### 2026-09-27 — main — decision: no Define reopen; the folder layout is a Design decision
- Corrects the previous entry. The user pointed out that the problem statement is unchanged and that the folder structure is a design choice, not a problem. Checked: the only REQ text that names `requirements.md` is REQ-009's criterion, which `define/requirements.md` still satisfies, and the glossary's "session artifact" line, which describes where the output lands. Design records how it reads that line.
- Define stays complete. No new REQ. The "don't overcrowd" principle and the `define/` layout become Design decisions D12 and D13.

### 2026-09-27 — main — decision: Close fold-back mapping for define/ docs
- The user asked how each Define doc is folded into the Diátaxis docs tree at Close. Today `close-foldback.md` has no per-section mapping, and nothing covers diagrams.
- Agreed rule: a section that's still true once the feature has shipped goes into docs, and anything about how we got there stays in the archive. Needs, stakeholders and outcomes go to `explanation/<domain>/overview.md`. Live REQs and NFR measures go to `reference/<domain>/`. Context and to-be diagrams go to the domain overview. `index.md`, `framing.md`, evidence, appetite, struck rows, 25010 N/A reasons, and the as-is, impact-map and traceability diagrams stay in the archive. How-to comes from Implement, not Define.
- REQ, DES and VER IDs are banned from as-built docs. The `Origin: #issue` line is the only way back.
- Becomes a new DES item and D14 in this revision, sent to the Design agent. Out of scope: doc-maintainer's S1 step still reads the old plan format → #41.

### 2026-09-27 — main — handoff: orchestrator → compass-labs:design (artifact view, define/ layout, Close fold-back)
- **Input:** the three 2026-09-27 decisions above. Task: add an artifact view with this session as the before and after, D12 (main doc plus sub-docs by tier), D13 (the define/ layout) and its ripple changes (check-traceability, feature.json, guard hook, paths), and D14 (the Close fold-back mapping into Diátaxis, no session IDs in as-built docs).
- **Output:** done (DES-019..023, D12–D14); files_changed: design.md

### 2026-09-27 — compass-labs:design — attempt: design.md revised with the artifact view, the define/ folder layout and the Close fold-back
- Added an Artifact view: each Define artifact marked new, changed, superseded or unchanged; a file tree per tier; this session as the worked before (root requirements.md, 148 lines) and after (full-tier define/, illustration only, D6); a Close fold-back example; and Design's reading of the "session artifact" glossary line as the define/ folder.
- New decisions D12 (a main doc plus sub-docs by tier, called the "main doc"), D13 (the define/ layout; rejected: root requirements.md as the main doc with define/ beside it, and flat sibling files) and D14 (Close folds still-true content into Diátaxis docs; no REQ, DES or VER IDs in as-built docs). DES-008 is rewritten as templates/define/, and DES-018 is now an example folder.
- New DES-019 (check-traceability reads define/requirements.md, root fallback, fixtures for both layouts), DES-020 (folder artifact in feature.json plus the guard: fixed file list, prefix ownership and freezing, one layout per session), DES-021 (plugin path updates), DES-022 (as-built docs at Close) and DES-023 (close-foldback.md mapping; the doc-maintainer S1 fix is out of scope as a follow-up).
- For the gate: confirm D6–D14; the frozen Non-goal "Changing Close's fold-back" is read as covering the README and anchor only; no numbered session IDs were found in docs/; confirm the layout refinements (fixed file list, NFR measures and assumptions in quality.md, one layout per session, ADR-003 covering D12–D14). Kept flags: D10, the symptom-vs-cause verdict and the Bugfix column.

### 2026-09-27 — main — decision: Design gate answers (D6–D14)
- The user is happy with the design overall. D7, D9, D11, D12, D13 and D14 are approved as they stand, and the agent's layout refinements are accepted.
- **D6, reframed:** there is no bulk migration of past sessions. A repo a year into using compass-labs has many historical features, and migrating them session by session is impractical and pointless. The new standard applies to new sessions. A future feature that touches an existing feature brings that feature's material up to the new standard as part of its own work.
- **D8, refined:** a Won't meaning "we will never do this" is struck through with its reason. A Won't meaning "not this session, later" isn't kept as a live row, but it must not disappear: it's recorded as deferred with its follow-up issue.
- **D10, changed:** the traceability diagram's form is chosen per case, for reviewability. A simple set uses `requirementDiagram`, and a complicated one uses `flowchart`. A trace too big to review is a prompt to ask the user whether the feature should be split into two.
- **Principle:** don't be rigid. Real work doesn't fit a framework neatly, so the standards give defaults and judgement calls, not hard rules. This extends REQ-029.
- D11 stays. Refining the Compass artifact repository as a bench test and eval is deferred to #42.

### 2026-09-27 — main — handoff: orchestrator → compass-labs:design (fold in Design gate answers)
- **Input:** the "Design gate answers (D6–D14)" entry above. Task: reframe D6 as no bulk migration, give deferred Won'ts a recorded home, choose the traceability form per case, add the no-rigidity principle, and name #41 and #42.
- **Output:** done; files_changed: design.md

### 2026-09-27 — compass-labs:design — attempt: design.md revised to the Design gate answers (D6, D8, D10, no-rigidity principle)
- D6 reframed as no bulk migration: past sessions are never migrated; the new standard applies to new sessions; a later feature that touches an existing one brings its as-built docs up to the standard. Kept the root-layout fallback in check-traceability and the guard, and one layout per session.
- D8: a "never" Won't is struck through with its reason. A "later" Won't moves to a `## Deferred` table in define/requirements.md (`Follow-up | Was | Requirement | Reason`, issue link required and first), so check-traceability ignores it like a struck row. Added fixture case (e) under DES-019. At Close it stays in the archive and the issue carries it forward (D14).
- D10: the traceability form is chosen per case (requirementDiagram for a simple set, flowchart LR for a complicated one), as guidance. A trace too big to review prompts Define to ask whether the feature should be split. Updated DES-017's check and rendering rules, and dropped the research-lean flag.
- Added the "Defaults, not rigid rules" principle to the Approach (extends REQ-029) and softened form-only checks. The mechanical gate checks are unchanged. D11 notes follow-up #42; DES-023 names #41.
- Open questions: all resolved; D6–D14 are confirmed at the gate after this revision. Status: Draft (ready for Design milestone).

### 2026-09-27 — main — milestone: ✅ Design complete
- The user approved design.md: DES-001..023 covering REQ-001..046 (REQ-012 struck), with D1–D14 confirmed. Open questions: all resolved.
- New since the first draft: the artifact view with this session as the before and after, the `define/` folder (D12–D13), the Close fold-back mapping into Diátaxis (D14), D6 as no bulk migration, deferred Won'ts (D8), the per-case traceability form (D10), and the "defaults, not rigid rules" principle.

## Phase: Implement

### 2026-09-27 — main — handoff: orchestrator → compass-labs:implement (tasks.md from DES-001..023)
- **Input:** Design complete. Task: write tasks.md and execute it, one commit per task, plumbing test-first, with DES-014's anchor wording returned for the user's approval (D1) and DES-022 deferred to Close.
- **Output:** blocked on the anchor wording (19 of 21 tasks done); files_changed: tasks.md plus the code, skills, templates, agents and docs listed in tasks.md

### 2026-09-27 — compass-labs:implement — attempt: tasks.md written and 19 of 21 tasks done
- tasks.md turns DES-001..023 into 21 tasks, one commit per ticked task. `bash tests/run.sh` was green after each, and the final run is 15 passed, 0 failed.
- Done: DES-001..013, DES-015..021, DES-023, and the README refresh outside the anchor (DES-014, task 19).
- The guard was checked against this session: tasks.md and log.md writes are allowed, and define/ is blocked (one layout per session, D6).
- Every shipped diagram renders with mermaid-cli, using the system Chrome.

### 2026-09-27 — compass-labs:implement — note: deviations from design recorded in tasks.md
- marketplace.json's explicit skill list gets framing and problem-statement, because marketplace_test.sh requires it. The design doesn't name the file.
- Task 9 was done before task 7, because a skill folder without SKILL.md fails the same test.
- Extra test cases were added, and the worked example's index.md has no ../log.md link. Neither changes behaviour.

### 2026-09-27 — compass-labs:implement — note: blocked on the user's approval of the compass-labs anchor wording
- Task 20 (DES-014, the README Project anchor) needs the user to approve the drafted wording. Under D1 the orchestrator writes it. Task 21 (DES-022) is deferred to Close.

### 2026-09-27 — main — decision: compass-labs project anchor approved
- The user shaped the wording over several rounds:
  - Ground it in common, established enterprise frameworks rather than invented methods.
  - Scope covers research and consulting engagements as well as software development.
  - Plain engineering language, with no marketing tone.
- Vision: AI-assisted delivery work, covering software development, research and consulting, based on common established frameworks used by enterprise teams.
- Mission: a Claude Code plugin that runs each piece of work as a session, from problem framing to a documented outcome, with one common framework per stage (SCQ, MoSCoW, EARS and Given/When/Then, ISO/IEC 25010, MADR, C4, Diátaxis).
- Scope and non-goals are as written in README.md. Consulting is listed as planned, tracked as #43. Other tools (SpecKit, BMAD) are deliberately not named in the anchor.
- Orchestrator wrote the anchor (D1). The Overview paragraph links to it, and the intro line drops "software" (anchor contract, check 6). Task 20 (DES-014) is ticked in the same commit.

### 2026-09-27 — main — note: plugin descriptions aligned with the anchor
- At the user's request, the "full-stack applications" wording in plugin.json, marketplace.json and CLAUDE.md was replaced to match the project anchor, and recorded as a deviation in tasks.md. The GitHub repo description was updated to the same wording.

### 2026-09-27 — main — milestone: ✅ Implement complete
- The user approved. Tasks 1–20 in tasks.md are done: DES-001..021 and DES-023, with the README anchor (DES-014) written by the orchestrator under D1. Task 21 (DES-022, the as-built session docs) is deferred to Close.
- `bash tests/run.sh`: 15 passed, 0 failed. The deviations are recorded in tasks.md (marketplace.json skill list, task order, extra tests, the worked example's header, plugin descriptions).

## Phase: Test

### 2026-09-27 — main — handoff: orchestrator → compass-labs:test (verification.md for REQ-001..046)
- **Input:** Implement complete. Task: at least one VER per live REQ, checked against the actual files, tests and behaviour. Render every shipped diagram, check the worked example item by item, check the README anchor against the contract, and run check-traceability. Record failures; don't fix them.
- **Output:** done (42 of 45 live REQs pass); files_changed: verification.md

### 2026-09-27 — compass-labs:test — attempt: verification.md written; 42 of 45 live REQs pass
- 37 VER rows cover REQ-001..046 (REQ-012 struck). `bash tests/run.sh` at 83ee33b: 15 passed, 0 failed. mermaid-cli 12.0.0 rendered every shipped diagram (reference 11/11, define template 4/4, worked example 4/4) plus design.md's 4, with no errors.
- README anchor passes all six anchor-contract checks. Behaviour REQs were verified by reading the skill and agent instructions; no live session was run.
- check-traceability.sh exits 1: REQ-025, REQ-038 and REQ-040 have no passing VER.

### 2026-09-27 — compass-labs:test — note: worked example fails REQ-025 and REQ-040, so REQ-038 fails
- REQ-025: examples/feature-full/problem.md has untagged claims in Context (l.8, l.10) and Why now (l.28). The standard's Good examples for Context and Impact (types/feature.md l.39, l.63) are untagged too.
- REQ-040 (a judgement call): the context diagram has no node for the admin audit log (REQ-006) or the auth log (OUT-01's signal), which quality.md lists as dependencies.
- Observation: example REQ-009 (accessibility) has no NFR measures row.
- Fixing these needs the example (and possibly the standard's examples) changed. The Test agent didn't change them.

### 2026-09-27 — main — decision: fix the worked-example gaps found in Test
- The user approved the fixes and asked for Test to continue until it's complete, with evidence.
- REQ-025: tag every claim in the example's Context and Impact/why-now (plus the index summary's pointer to the evidence), and tag the "Good" examples in problem-statement/types/feature.md. The rule stays as it is, with no untagged claim.
- REQ-040: the admin audit log and the auth log are internal to the wiki, so quality.md no longer lists them as external dependencies and says why. The context diagram is unchanged.
- Observation: add a WCAG 2.2 A/AA measures row for the example's REQ-009.
- tasks.md is frozen (Implement complete), so the fix is recorded as an orchestrator deviation in tasks.md in this commit. Test re-verifies VER-019, VER-032 and VER-037.

### 2026-09-27 — main — handoff: orchestrator → compass-labs:test (re-verify after the fixes)
- **Input:** the fix decision above (commit 58f91dd). Task: re-read the changed files independently and update VER-019, VER-025, VER-032 and VER-037.
- **Output:** done; files_changed: verification.md

### 2026-09-27 — compass-labs:test — attempt: worked-example fixes re-verified at 58f91dd; every REQ has a passing VER
- Re-read examples/feature-full/problem.md sentence by sentence: Context, Evidence and Impact/why-now claims are all tagged, and so are the standard's Good examples. VER-019 (REQ-025) fail → pass.
- quality.md now says the audit log and auth log are internal to the wiki. The context diagram shows every external system still named. VER-032 (REQ-040) fail → pass.
- The example meets REQ-023–037 and REQ-039–042, and its 4 diagrams re-render. VER-037 (REQ-038) fail → pass. The VER-025 observation is resolved.
- `bash tests/run.sh`: 15 passed, 0 failed. check-traceability.sh exits 0.

### 2026-09-27 — compass-labs:test — note: minor points left in the worked example (not fails)
- The outcome baselines in problem.md l.34–35 aren't tagged; they repeat the tagged Evidence, but l.19 is an average wait while OUT-01 measures a median.
- quality.md l.36 says "inside the context diagram's system boundary", but the box drawn is the work in scope, not the whole wiki.

### 2026-09-27 — main — milestone: ✅ Test complete
- The user asked for Test to run until it's complete. Gate check a ran: `check-traceability.sh` exit 0 at 58f91dd, and the orchestrator re-ran it independently along with `tests/run.sh` (15 passed, 0 failed).
- verification.md: 37 VER rows, 0 Fail, covering REQ-001..046 (REQ-012 struck). Behaviour REQs were verified by reading the instructions, with no live run, as noted in each row. Two minor worked-example wording points are logged above and not fixed.

## Phase: Deploy

### 2026-09-27 — main — handoff: orchestrator → compass-labs:deploy (release.md, v1.2.0, PR)
- **Input:** Test complete, and the user approved running Deploy. Task: follow the repo's release workflow, bump the version (MINOR), open the PR to main without merging, and write release.md with Completeness.
- **Output:** done; files_changed: .claude-plugin/plugin.json, release.md

### 2026-09-27 — compass-labs:deploy — attempt: release completeness checked, no gaps
- All 14 skills listed in marketplace.json are complete and match `skills/` exactly, including framing and problem-statement. All 7 agents and all 3 hook scripts are present, with no stubs.
- Tasks 1–20 ship complete. Task 21 (DES-022) is deferred to Close and isn't part of this release.

### 2026-09-27 — compass-labs:deploy — attempt: v1.2.0 bumped on branch, PR #44 opened
- plugin.json went from 1.1.0 to 1.2.0 in 95dbe79. `tests/run.sh`: 15 passed, 0 failed. `claude plugin tag --dry-run` would create `compass-labs--v1.2.0`, with the same 4 warnings as v1.1.0.
- PR https://github.com/dkoenawan/compass-labs/pull/44 opened to main and not merged. release.md committed in 03aae5a.

### 2026-09-27 — compass-labs:deploy — note: steps after the merge are still to run
- Squash-merge #44, then on main: `claude plugin tag --push`, `claude plugin update compass-labs@compass-labs`, the confirmation checks and a restart. This follows the v1.1.0 split, because merges are squash-only.

### 2026-09-27 — main — milestone: ✅ Deploy complete
- The user approved. Gate check a2: release.md's Completeness section lists only complete components and leaves none out. DES-022 is explicitly deferred to Close.
- v1.2.0 is on the branch (95dbe79), and PR #44 is open to main. The squash-merge, `claude plugin tag --push` and `claude plugin update` run after the merge.

## Phase: Close

### 2026-09-28 — main — handoff: orchestrator → compass-labs:close (fold-back incl. DES-022)
- **Input:** Deploy complete; the user asked to close the session and will merge PR #44 themselves. Task: fold the session back into the as-built docs, including DES-022 (the as-built session docs describe the `define/` folder). Uncommitted fold-back edits are already in the working tree from an earlier, unlogged pass (7 modified docs, plus new `docs/explanation/framing/` and `docs/reference/framing/`). Review and keep them, and complete them rather than redo.
- **Output:** done; files_changed: docs/explanation/framing/overview.md (new), docs/reference/framing/tiers-and-anchor.md (new), docs/explanation/session/overview.md, docs/explanation/plan/overview.md, docs/explanation/solution-design.md, docs/reference/session/workflow-and-artifacts.md, docs/reference/session/hooks-and-scripts.md, docs/registry/index.md, docs/registry/patterns.md

### 2026-09-28 — compass-labs:close — note: Fold-back ready — define/ folder, framing and anchor folded into as-built docs
- Reviewed the uncommitted fold-back from an earlier, unlogged pass. It was accurate and complete, so it was kept, and only its dates were moved to 2026-09-28.
- Checked against hooks/session-guard.sh, feature.json, check-traceability.sh, the define/ templates, anchor-contract.md, session SKILL.md gate a3, agents/define.md and both types/feature.md tier tables. Everything matches.
- DES-022 (task 21) is covered: the session reference and explanation docs and the plan overview describe the define/ folder. That includes the index.md main doc, sub-docs by tier, and the root requirements.md kept only for past sessions. The old "folder next to its Markdown file" wording is rewritten.
- New framing domain: docs/explanation/framing/overview.md (why it exists and who it's for, how it works, context diagram) and docs/reference/framing/tiers-and-anchor.md (tiers, checks by tier, Feature content by tier, anchor contract, framing block).
- The session ID ban holds: no (REQ|DES|VER)-[0-9] outside docs/sessions/. Each touched doc has one Origin line ("#22 · #23" where #22 was already there, "#23" on the new files).
- Stays in the archive: framing record, evidence, appetite, struck and deferred rows, impact map, traceability. No constructs to flip, because the registry has none.

### 2026-09-28 — main — decision: Task 21 (DES-022) ticked in the frozen tasks.md
- The Close fold-back covers DES-022. The as-built session and plan docs describe the `define/` folder. tasks.md is frozen, so the tick is amended under this decision, in the Close commit.

### 2026-09-28 — main — milestone: ✅ Session closed
- The user approved. The fold-back is committed with this entry: `define/` folder (DES-022) in the session and plan docs, a new framing explanation and reference, registry patterns "Framing names no phase" and "One project anchor, written by the orchestrator", and no session IDs in the as-built docs. Task 21 ticked in 5c7796f.
- PR #44 is left open for the user to merge. After the merge, on main: `claude plugin tag --push` and `claude plugin update compass-labs@compass-labs`. Issue #23 is closed now, at the user's request. Follow-ups #37–#43 stay open.
