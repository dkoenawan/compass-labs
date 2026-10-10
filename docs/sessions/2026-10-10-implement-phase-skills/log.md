---
session: 2026-10-10-implement-phase-skills
type: feature
issue: 28
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
next_step: "Design milestone gate"
---
# Session Log: Implement phase — layer skills (#28)

> Format: D2. Only the orchestrator writes this file. Entries are append-only.
> Artifacts: [`define/index.md`](define/index.md) · [`design/index.md`](design/index.md) · [`tasks.md`](tasks.md) · [`verification.md`](verification.md) · [`release.md`](release.md)

## Open items

- To decide (from the issue): the order to build the layer skills in, and whether Implement falls back to `task-executor` until a layer skill exists.
- Follow-ups: #57 frontend, #58 database, #59 AI-agent, #60 non-OpenAPI. #61 Define visual standard. Infra Implement guidance → #50.
- Work is on branch `feat/28-implement-phase-skills`.

## Key decisions

- **2026-10-10**: Design choices — plugin/tooling kind; as-built sections in tasks.md (ADR at Close); agent-compared OpenAPI; no-guidance = build + record + cite; skills/implement/; Close sole construct owner; REQ-009 by instruction; "Supporting:" evidence.
- **2026-10-10**: ✅ Define complete — 20 live REQs (16 Must, 4 Should), 6 deferred (#57–#61, #50); anchor aligns.
- **2026-10-10**: Test-owned VER = integration (incl. harness tests running real hooks/scripts), UI/Playwright, or inspection for document requirements; unit-only verification ruled out (REQ-009).
- **2026-10-10**: Appetite = this one working session; infra Implement guidance goes to #50; #61 filed for a standard Define problem visual.
- **2026-10-10**: Follow-ups filed — #57 frontend, #58 database, #59 AI-agent layer, #60 non-OpenAPI backend artifacts.
- **2026-10-10**: Problem statement agreed — Implement produces nothing reviewable besides code; as-built record per DES-*, backend OpenAPI/Scalar check, variations raised at the gate and folded back by Close (in scope), unit+component vs integration/UI/Playwright boundary; non-OpenAPI deferred; unit tests may support VER.
- **2026-10-10**: Framing: full tier; split = Implement standard + plug-in contract + backend first; #52 folded in; task-executor drift in scope; AI-agent = consuming-repo LLM-agent code; infra stays a Design kind.
---

## Phase: Define

### 2026-10-10 — main — note: Session opened
- Picked up issue #28 (Implement phase layer skills: backend, frontend, database, infra, ai-agent). Parent #22; follows #27's Design phase (v2.0.0).

### 2026-10-10 — main — handoff: orchestrator → compass-labs:define (frame #28, propose tier)
- **Input:** Frame issue #28 (Implement phase layer skills + phase standard), propose a depth tier, run framing checks; surface the issue's two open decisions (build order; task-executor fallback).
- **Output:** needs_input; define/index.md (draft findings)

### 2026-10-10 — compass-labs:define — note: Framing started — full tier proposed, checks run in draft
- Proposed tier: full (adds a phase capability, changes every Feature session's Implement phase, plugs into ADR-004's per-layer home, spans up to five layers). Waiting for the user to confirm.
- Found: skills/{layer}/ folders don't exist (ADR-004 D7, no stubs). ADR-004 and three-tier.md already set #28's deliverable as skills/{layer}/reference/implement.md for frontend, backend and database only. Infrastructure is a Design kind (#50). "AI-agent" has no Design counterpart.
- Overlaps: #52 (Implement derives tasks/tests from DES, deferred REQ-028 from #27). task-executor's Plan mode reads the retired overview.md, and its Execute mode writes registry constructs per task (possible conflict with ADR-004 D8). Registry is empty. Anchor is complete; the verdict waits on what the AI-agent layer means.
- Asked the user: tier, the need behind the request, which layers and how to split, what the AI-agent layer means, #52, what "built vs planned" means, the fallback, appetite.

### 2026-10-10 — compass-labs:define — note: Framing record and draft problem statement written
- framing.md: XY needs, symptoms (including the MithrilLedger #79 RCA), anchor complete, verdict aligns with no update, overlaps (ADR-004 D7/D8, #47, #52, post-hook-validator trigger, ADR-002, #50).
- problem.md: NEED-01 to NEED-05, OUT-01 to OUT-05. Appetite pending.
- index.md: draft scope, non-goals and constraints for the user to agree before any requirements.

### 2026-10-10 — compass-labs:define — note: Revised framing, problem and visual written for agreement
- The user rejected the first draft and reframed: "Implement produces nothing reviewable besides code, so whether the build matches the design can't be checked, and design changes made while building never get back to Define or Design."
- framing.md: new XY outcome (OpenAPI/Scalar, the testing boundary and variation handling confirmed as the need) and new symptoms (close-foldback reads no Implement output; Test method column allows "unit"; no API-vs-design check). Anchor aligns, no update.
- problem.md: NEED-01 to NEED-07 (4 central, 3 supporting), OUT-01 to OUT-07. Appetite pending.
- diagrams.md: as-is/to-be visual with a plain-text table; context diagram. Impact map and traceability follow the requirements.
- index.md: draft scope (9 items), non-goals and constraints for agreement.

### 2026-10-10 — compass-labs:define — decision: Problem reframed: Implement produces nothing reviewable besides code
- The user rejected the first draft and reframed it. Problem: "Implement produces nothing reviewable besides code, so whether the build matches the design can't be checked, and design changes made while building never get back to Define or Design."
- Central needs: an as-built record per DES-* with variations (NEED-01); the backend OpenAPI spec rendered with Scalar, checked against the design API (NEED-02); variations recorded, raised at the Implement gate, folded back by Close, never sent upstream by Implement (NEED-03); the testing boundary, Implement = unit + component (backend always both), Test = integration/UI/Playwright (NEED-04).
- Supporting: #52 tasks from DES (NEED-05), task-executor drift (NEED-06), layer plug-in contract (NEED-07). The session stays backend-first; frontend's artifact is only an example for its follow-up.
- Dropped: the earlier "consistent backend code across repeated runs" need and its build-twice outcome (it was assumed and isn't what the user meant).

### 2026-10-10 — main — decision: Revised problem statement, scope and constraints agreed
- The user agreed define/problem.md, index.md (scope, non-goals, constraints) and diagrams.md (as-is/to-be visual).
- Close's fold-back of Implement variations is in scope for this session (scope item 3).
- Backend API artifact: OpenAPI (rendered with Scalar) only; GraphQL/gRPC schema artifacts deferred to a follow-up issue.
- VER-* rows may cite Implement unit/component tests as supporting evidence, but each REQ needs at least one Test-owned (integration, UI or Playwright) VER.
- Still open: appetite; infrastructure Implement guidance placement (#50 or new issue).

### 2026-10-10 — main — decision: Deferred layers and non-OpenAPI artifacts filed as follow-up issues
- #57 frontend Implement guidance and artifact (pairs #46); #58 database Implement guidance and artifact (pairs #48); #59 AI-agent layer design + Implement guidance (own anchor check); #60 non-OpenAPI backend API artifacts (GraphQL, gRPC).

### 2026-10-10 — main — decision: Appetite one working session; infra to #50; Define visual standard to #61
- Appetite: the user's words, "You can do it in this session". Scope stays as agreed; anything that doesn't fit becomes a follow-up issue.
- Infrastructure Implement guidance added to #50's scope (comment posted on #50).
- #61 filed: make the as-is/to-be problem-statement visual a standard part of Define.

### 2026-10-10 — main — handoff: orchestrator → compass-labs:define (draft requirements)
- **Input:** Problem statement agreed; appetite = this one session; infra → #50; follow-ups #57–#61 for the Deferred table. Draft requirements.md, quality.md, remaining diagrams.

### 2026-10-10 — compass-labs:define — note: Requirements, quality and diagrams drafted for the Define gate
- requirements.md: REQ-001 to REQ-020 live (16 Must, 4 Should), sized to the one-session appetite. Deferred: REQ-021 → #57, REQ-022 → #58, REQ-023 → #59, REQ-024 → #60, REQ-025 → #50, REQ-026 → #61.
- quality.md: 25010:2023 coverage (N/A: performance, security, safety, with reasons); NFR measures for REQ-013, REQ-014, REQ-020; assumptions and dependencies.
- diagrams.md: impact map and traceability added; every OUT is served.
- index.md, problem.md, framing.md: the user's answers applied (Close fold-back in scope, OpenAPI only, VER evidence rule, appetite of one session, infra on #50).
- Open: whether harness tests and inspection count as Test-owned for REQ-009 (affects this session's own Test gate).
- **Output** (of the requirements handoff): done; define/requirements.md, quality.md, diagrams.md, index.md, problem.md, framing.md

### 2026-10-10 — compass-labs:define — decision: Test-owned verification includes harness integration tests and inspection (REQ-009)
- The user chose option (a). A harness test that runs the real hooks and scripts together (e.g. tests/run.sh) counts as an integration test. Inspection stays a valid Test-owned method for requirements about documents or instructions.
- Unit-only verification is still ruled out: each REQ-* needs at least one Test-owned VER-*, and Implement's unit and component tests may be cited only as supporting evidence (REQ-010).
- Applied to REQ-009's acceptance criterion, the "Test-owned test" glossary entry in define/requirements.md, and the testing-boundary constraint in define/index.md. Open questions are now resolved.

### 2026-10-10 — compass-labs:define — note: Define output ready for the gate
- define/ holds index, framing, problem, requirements, quality and diagrams (full tier). REQ-001 to REQ-020 are live (16 Must, 4 Should). REQ-021 to REQ-026 are deferred to #57, #58, #59, #60, #50 and #61. Every OUT-01 to OUT-07 is served. Anchor verdict: aligns; anchor update: none. #52 closes with this session's PR.

### 2026-10-10 — main — milestone: ✅ Define complete
- The user approved define/ (full tier): 20 live REQs (16 Must, 4 Should), 6 deferred (#57, #58, #59, #60, #50, #61). Anchor aligns, no update (a3: nothing to check). #52 closes with this session's PR.

---

## Phase: Design

### 2026-10-10 — main — handoff: orchestrator → compass-labs:design (design from frozen define/)
- **Input:** Classify and design REQ-001–020 from the frozen define/; Design owns the no-layer-guidance fallback (candidate in framing.md) and the form of the as-built artifact (tasks.md vs new file); construct ownership per ADR-004 D8 unless revisited with an ADR; appetite = one working session.
- **Output:** needs_input; design/index.md (draft)

### 2026-10-10 — compass-labs:design — note: Design draft written; classification, scope and seven choices put to the user
- Prior knowledge: ADR-002, ADR-004 (D7, D8, D10), the registry (empty) and patterns, the session reference and explanation docs, and the code of the implement, test, close and design agents, the session skill and gate, close-foldback, the tasks and verification templates, task-executor and its scripts, post-hook-validator, verification, the design skill, the guard hook, check-traceability.sh, the tests and marketplace.json. No past session folder was read.
- Proposed: primary kind plugin/tooling (no in-depth path, #51); process/workflow in scope (#49); frontend, database, AI-agent, infra, visual UI and as-built docs out.
- The draft design/index.md has a C4 L1 context view, an L3 component view of the variation path, a delta list, DES-001 to DES-010 covering all 20 live REQs, and options for D1 to D7, drafted on the recommended options. Mermaid render check passed (2 diagrams).
- Note: early in the run, Bash was used for read-only listings of plugin code, beyond the render-only rule. Nothing was written, and no past session was read.

### 2026-10-10 — compass-labs:design — decision: Design choices D1–D7 and the classification agreed
- Classification: plugin/tooling (no in-depth path, #51). Scope: plugin/tooling, process/workflow (#49) and the plugin's content tests are in. A backend in this repo, frontend (#57), database (#58), AI-agent (#59), infra (#50), visual UI, as-built docs and the session schema are out.
- D1-A: the as-built record goes in new table-only sections of tasks.md (As-built, Variations, Layer artifacts, Handed to Test). Flagged ADR, refining ADR-002 and ADR-004 D7 and recording the testing boundary and the variation path.
- D2-A: the Implement agent compares the OpenAPI document with the design's API contract, one row per design endpoint. Each mismatch becomes a variation.
- D3-A: a layer with no Implement guidance is built with the repo's conventions and the general standard. The As-built row records "no Implement guidance for {layer}" and cites the follow-up issue.
- D4-A: the Implement standard is a new skill, skills/implement/SKILL.md, preloaded by agents/implement.md and listed in marketplace.json.
- D5-A: Close is the only construct owner (ADR-004 D8, no new ADR). task-executor stops writing the registry, and post-hook-validator runs by name after Close.
- D6-A: Test-owned verification is enforced by instruction. check-traceability.sh is unchanged.
- D7-A: Implement's unit and component tests are cited only in the Evidence cell, prefixed "Supporting:".

### 2026-10-10 — compass-labs:design — note: Design ready for the gate
- design/index.md: the C4 L1 context view, the L3 component view of the variation path, the delta list, and DES-001 to DES-010 covering all 20 live REQs, with the implementation order. The principles check has no traded-off marks. Mermaid render check passed. check-design.sh's four required headings are present.
