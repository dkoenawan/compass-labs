<!-- tier: full -->
# Framing: Implement phase — an as-built artifact, the backend API artifact and the testing boundary

> Part of [index](index.md) · Define

## Problem checks

### Solution-first (XY)

- **Need behind the request:** #28 names a fix: "build Implement-phase skills for backend, frontend, database, infra and ai-agent, plus the phase's standard document". The user reframed the need (Define answers, 2026-10-10):

  > Define has standard documentation and Design has ADRs and visual design, but Implement produces nothing reviewable besides code. During implementation the build can vary from the design, and unit tests may not line up with it. Those changes need to get back upstream, and today they go nowhere.

  In one line, as the user approved it: **Implement produces nothing reviewable besides code, so whether the build matches the design can't be checked, and design changes made while building never get back to Define or Design.**

  The needs behind it, as confirmed:
  - **Central:**
    - an as-built record of what was implemented, per `DES-*` (NEED-01);
    - a per-layer artifact that shows the built layer matches its design: for backend, the built API checked against the design's API (NEED-02);
    - variations found while building get back upstream (NEED-03);
    - a stated boundary between Implement's own testing and the Test phase (NEED-04).
  - **Supporting:**
    - tasks derived from the `DES-*` items (#52, NEED-05);
    - `task-executor` in step with the lifecycle (NEED-06);
    - a contract for adding the next layer (NEED-07).

  The earlier "consistent backend code across repeated runs" need was dropped. It was assumed, and the user said it wasn't what they meant.
- **Outcome:** the user confirmed the following as the need itself:
  - **The backend artifact:** an OpenAPI spec, rendered with Scalar, produced alongside the code and checked against the API in `design/`. OpenAPI and Scalar are already the backend stack default (`skills/design/reference/stack-defaults.md`).
  - **The testing boundary:** Implement does unit and component tests only, and backend always gets both. The Test phase does integration, UI and Playwright tests.
  - **Where variations go:** a variation found while building is recorded in Implement's artifact and raised at the Implement milestone. Implement doesn't send it upstream. Folding it back is Close's job.

  The remaining fixes the issue proposed are in Candidate solutions.

**Candidate solutions:**
- Layer skills under `skills/{layer}/`, one per layer, each with a single responsibility (from the issue). ADR-004 D7 already fixes the home as `skills/{layer}/reference/implement.md` (see Overlaps).
- **The form of the as-built record:** a new section of `tasks.md`, a richer "Deviations from design" section, or a separate Implement artifact. The last would change `feature.json`, the guard hook and ADR-002's one-artifact-per-phase rule. Left to Design.
- **How the OpenAPI spec is checked against the design:** a manual comparison at the gate, a script that compares design endpoints with spec paths, or a contract test. Left to Design.
- **Frontend's future artifact**, for example a component inventory with screenshots. Recorded only as an example for its follow-up issue, not designed here.
- **The fallback when a layer has no Implement guidance yet:** fall back to `task-executor` plus general judgement (from the issue), or cite the layer's follow-up issue the way Design does for a missing layer standard (`skills/design/kinds/three-tier.md`). The user left this to Design.

### Symptom and cause

- **Observed symptoms:**
  - **Nothing reviewable besides code:**
    - Implement's only artifact is `tasks.md`, a checklist plus a free-prose "Deviations from design" section [observed: `skills/session/templates/tasks.md`; `agents/implement.md`].
    - Past sessions recorded deviations per task, with no status per `DES-*` [observed: archived `tasks.md` of #22, #23, #27].
  - **Built vs designed can't be checked:**
    - A consuming repo's `task-executor` run opened a PR missing 15 new frontend files (1,349 lines), found only in a manual review [observed: `docs/explanation/reviews/task-executor-untracked-files-not-committed.md`, MithrilLedger #79].
    - No skill checks a built API against the design's API contract [observed: no such check in `skills/`. OpenAPI and Scalar appear only as a default in `stack-defaults.md`, in `bootstrap-new-project` and in `doc-maintainer`].
  - **Variations go nowhere:**
    - Close reads `define/`, `design/` and `log.md`'s Key decisions. It reads `tasks.md` only for how-to guides [observed: `skills/session/reference/close-foldback.md`, step 1 and line 37]. So a variation written in `tasks.md` isn't folded back, and the as-built docs describe the design rather than what was built.
    - Design takes prior knowledge only from those as-built docs [observed: `skills/design/SKILL.md`, prior-knowledge rule]. So the next session's Design builds on the unvaried design.
    - The user reports that variations found while building ("we tested this, it doesn't quite work, we need a variation") currently go nowhere [observed: user, Define answers 2026-10-10].
  - **Testing boundary unstated:**
    - The Test agent's `VER-*` method column allows "unit/e2e/manual" [observed: `agents/test.md`].
    - The Implement agent says nothing about which tests it writes. It inherits `task-executor`'s single `test_command` [observed: `agents/implement.md`; `skills/task-executor/SKILL.md`].
    - Unit tests written during Implement may not match the design [observed: user, Define answers 2026-10-10].
  - **Supporting:**
    - Implement doesn't use the `DES-*` Result, Check and Depends-on columns [observed: #52].
    - `task-executor` Plan mode reads a retired `overview.md` [observed: `skills/task-executor/SKILL.md` Phase 4–5].
    - Constructs have two writers [observed: `task-executor` Step 5; `close-foldback.md`; ADR-004 D8].
- **Cause:**
  - Implement has no standard and no per-layer guidance. #22's decision Q11 deferred them to this issue [observed: #28 body; `agents/implement.md`].
  - Close's fold-back map covers only Define's and Design's output, because no Implement artifact existed to map [observed: `close-foldback.md`; assumed: that's why].
  - The missing per-`DES-*` record and API check explain the late discoveries like MithrilLedger #79 [assumed]. The RCA's own root cause is narrower: `git add` missed new directories [observed: the RCA].

## Anchor

- **State:** complete. The root `README.md` has exactly one `<!-- compass:anchor -->` / `<!-- /compass:anchor -->` pair. Vision, Mission, Scope and Non-goals are all present and non-empty. README lines 3 and 7 link to the anchor instead of restating it on their own. No conflicting restatement was found.
- **Verdict:** aligns
- **Rests on:**
  - Scope: "Standards for each session artifact, by session type and depth tier." The Implement artifact, with its as-built record and per-layer artifact, is a session artifact getting its standard.
  - Mission: "structures each piece of work as a session, from problem framing to a documented outcome." Variations reaching the as-built docs through Close makes the documented outcome match what was built.
  - Scope: "Hooks and scripts that enforce session structure and traceability." Any check of the built API against the design, or of the as-built record at the Implement gate, falls under this line.
  - Scope: "Supporting skills: … task execution …" Bringing `task-executor` in line keeps an existing supporting skill working.
  - Scope: "Works in any repository, independent of tech stack." OpenAPI with Scalar is the backend *default*. An established stack that produces OpenAPI is built in its own way (REQ-013). A backend with no OpenAPI (for example GraphQL or gRPC) is deferred to #60, where its own ecosystem's API description is checked (ADR-004 D10).
  - Non-goal: "Creating new methods where an established one exists." The backend artifact uses an established standard (OpenAPI), and the testing boundary uses the established unit, component and integration split.
  - Non-goal: "Replacing user approval at milestones." Variations are *raised* at the Implement gate for the user to decide on. Implement doesn't resolve them alone.
  - **Not judged here:** the AI-agent layer (code in consuming repos that builds LLM agents) is deferred to a sub-issue. It may *extend* Scope and must run its own anchor check.

### Anchor update

- **Action:** none
- **Elements:** none
- **Agreed text:** none

## Overlaps

- **ADR-004 D7 and `skills/design/kinds/three-tier.md` (a constraint):**
  - The per-layer home is `skills/{layer}/`, holding `SKILL.md`, `reference/design.md` and `reference/implement.md`.
  - For backend, this session delivers `skills/backend/reference/implement.md`, and `SKILL.md` unless #47 lands first. No stub folders for other layers.
- **The design's API contract (input):** `design/solution.md` names each frontend ↔ backend endpoint, its request and response shape, and its error cases. `design/backend.md` (#47) adds field-level detail. The OpenAPI check compares against these. Without #47, it compares against `solution.md` and the backend `DES-*` items.
- **`skills/design/reference/stack-defaults.md` (consistent):** the backend default already names OpenAPI rendered with Scalar. The backend guidance links to it rather than restating it (ADR-004 D10).
- **`close-foldback.md` (gap, central to NEED-03):**
  - Its map has no row for Implement's output, so variations aren't folded back.
  - Closing the gap means Close reads Implement's artifact.
  - The user put this change in scope (REQ-006).
- **`agents/test.md` and the `verification` skill (boundary, central to NEED-04):**
  - The `VER-*` method column allows "unit". The new boundary says Implement owns unit and component tests.
  - User decision: a `VER-*` row may cite Implement's unit or component tests only as supporting evidence, and each `REQ-*` needs at least one Test-owned `VER-*` (REQ-009, REQ-010).
  - `check-traceability.sh` reads only IDs, so the gate isn't affected.
- **#52 (Implement derives tasks and tests from `DES-*`):** folded into this session by the user's decision. It closes with this session.
- **ADR-004 D8 and `close-foldback.md` vs. `task-executor` Step 5 (conflict, in scope):** constructs have two writers, and ADR-004 D8 names Close. Design decides which owner wins.
- **`post-hook-validator` (interaction):** it's triggered by `task-executor`'s construct writes. Changing Step 5 has to say what happens to it.
- **ADR-002 (consistent unless Design adds an artifact):** Implement's artifact is `tasks.md`, and `REQ → DES → task → VER` stays. A second Implement file would refine ADR-002, the way ADR-003 and ADR-004 did for `define/` and `design/`.
- **#50 (infrastructure kind):** infrastructure stays a Design kind, not a layer. Its Implement guidance was added to #50's scope (deferred REQ-025).
- **#46 (frontend design) and #48 (database design):** their layers' Implement guidance and artifacts are #57 and #58 (deferred REQ-021, REQ-022). The AI-agent layer is #59, and non-OpenAPI backends are #60.
- **Construct registry:** empty (`construct_count: 0`). No construct overlaps were found.
