<!-- tier: full -->
# Problem: Implement phase — an as-built artifact, the backend API artifact and the testing boundary

> Part of [index](index.md) · Define · Visual: [as-is and to-be](diagrams.md#as-is-and-to-be)

**In one line:** Implement produces nothing reviewable besides code, so whether the build matches the design can't be checked, and design changes made while building never get back to Define or Design.

### Context

**Situation:**
- Define writes a standard `define/` folder (index, framing, problem, requirements) [observed: ADR-003].
- Design writes a `design/` folder with visual deltas, decisions flagged for ADRs, and a `DES-*` table giving each item's result, check and dependencies [observed: ADR-004].
- Implement writes code, plus `tasks.md`, a checklist with a free-prose "Deviations from design" section [observed: `agents/implement.md`; `skills/session/templates/tasks.md`].
- Test writes `verification.md` [observed: `agents/test.md`].
- Close folds Define's and Design's output into the as-built docs [observed: `skills/session/reference/close-foldback.md`].

**Complication:**
- Implement is where a design meets reality: a test shows something "doesn't quite work" and the build varies from the design [observed: user, Define answers 2026-10-10].
- Nothing reviewable shows those variations per `DES-*`, and nothing checks the built API against the designed one [observed: no such check in `skills/`].
- Close never reads Implement's output for variations [observed: `close-foldback.md` step 1], so the as-built docs, which the next Design reads as prior knowledge [observed: `skills/design/SKILL.md`], describe the design rather than what was built.
- Which tests belong to Implement and which to Test isn't stated either [observed: `agents/test.md` method column "unit/e2e/manual"; `agents/implement.md`].

### Need and stakeholders

Central:

- **NEED-01:** When an Implement phase finishes, the reviewer approving the Implement milestone wants a record of what was built for every `DES-*` (built as designed, deviated, or not built, each with a reason), with every variation listed, so they can check the build against the design and decide on each variation without reading the code.
- **NEED-02:** When an Implement phase builds or changes a backend API, the reviewer, and the developers who consume that API, want a machine-readable description of the API as built, checked against the API in the design, so they can confirm the built API is the approved contract. The user confirmed the form: an OpenAPI spec rendered with Scalar, produced alongside the code.
- **NEED-03:** When a variation from the design is found while building, maintainers of the project's as-built docs, and the later sessions that design from them, want the variation recorded in Implement's artifact, raised at the Implement milestone and folded back by Close, so the docs describe what was actually built.
- **NEED-04:** When code is tested during a session, the Implement agent, the Test agent and the reviewers of both want a stated boundary, so each kind of test has one owner and the reviewer knows where each piece of evidence comes from:
  - Implement writes and runs unit and component tests, and backend always gets both;
  - the Test phase runs integration, UI and Playwright tests.

Supporting:

- **NEED-05:** When Implement starts from an approved design, the user who approved it wants the tasks and their checks to come from each `DES-*`'s result, check and dependencies, so the solution isn't re-decided while building (#52).
- **NEED-06:** When a developer runs `task-executor` on a session from the current lifecycle, they want it to find that session's design and leave construct registration to one owner, so the plan resolves and the registry isn't written twice.
- **NEED-07:** When the next layer's Implement guidance and artifact are added (frontend, database, AI-agent), plugin maintainers want to plug them in by adding that layer's files, without changing the Implement phase, so each layer ships as its own issue. For example, frontend's artifact might be a component inventory with screenshots; that's decided in its own issue.

### Evidence

- Implement produces only code plus `tasks.md`, whose deviations are free prose per task, with no status per `DES-*` [observed: `skills/session/templates/tasks.md`; archived `tasks.md` of #22, #23, #27].
- The user can't see what was implemented compared with the design [observed: user, Define answers 2026-10-10].
- A consuming repo's PR left out 15 new frontend files, found only in a manual review [observed: `docs/explanation/reviews/task-executor-untracked-files-not-committed.md`, MithrilLedger #79]. A per-`DES-*` record would have surfaced the gap earlier [assumed].
- Variations found while building go nowhere today [observed: user, Define answers 2026-10-10]. Close reads only `define/`, `design/` and the log's Key decisions [observed: `close-foldback.md` step 1].
- The next session's Design reads prior knowledge only from the as-built docs [observed: `skills/design/SKILL.md`]. So an unfolded variation misleads later designs [assumed: no case recorded yet].
- Nothing checks a built API against the design's API contract [observed: no check in `skills/`]. The design does state that contract: endpoints, request and response shapes, error cases [observed: `skills/design/kinds/three-tier.md`].
- OpenAPI rendered with Scalar is already the plugin's backend default [observed: `skills/design/reference/stack-defaults.md`]. Consuming repos with a non-OpenAPI backend exist [assumed].
- The testing boundary is unstated: `VER-*` methods include "unit" [observed: `agents/test.md`], and Implement inherits one `test_command` [observed: `agents/implement.md`; `skills/task-executor/SKILL.md`]. Unit tests written during Implement may not match the design [observed: user, Define answers 2026-10-10].
- At least one session changed artifacts during Test, after its Implement milestone [observed: #23 `tasks.md`, "Test-phase fix (after the Implement milestone)"].
- Supporting:
  - Implement doesn't use the `DES-*` Result, Check and Depends-on columns [observed: #52].
  - `task-executor` Plan mode reads a retired `overview.md` [observed: `skills/task-executor/SKILL.md`].
  - Constructs have two writers [observed: `task-executor` Step 5; `close-foldback.md`; ADR-004 D8].

### Impact and why now

- **If nothing changes:**
  - Implement reviewers keep approving code without a per-`DES-*` view, so gaps surface late, in manual review [observed: the MithrilLedger #79 RCA].
  - Built APIs can drift from the approved contract unnoticed [assumed].
  - Variations stay in the session folder, so the as-built docs, and every later design that reads them, describe a system that wasn't built [observed: `close-foldback.md`; `skills/design/SKILL.md`].
  - Unit tests may be duplicated, or skipped, between Implement and Test [assumed].
- **Why now:**
  - Implement is the next phase in #22's order, after Define (#23) and Design (#27) [observed: #22 Q11].
  - Design v2.0.0 just shipped the structured `DES-*` handoff and the per-layer home that this work plugs into [observed: commit `401094b`].
  - The backend design standard (#47) is coming. It will produce `design/backend.md` API detail that has nothing to be checked against yet [observed: `skills/design/kinds/three-tier.md`].

### Success outcomes

| Outcome | Signal | Target | Checked when | For need |
|---|---|---|---|---|
| OUT-01 | `DES-*` items in a finished Implement phase that have an as-built status (built as designed, deviated, not built), with a reason for each status other than "built as designed" | 100% of the session's `DES-*` items, shown at the Implement gate | At the Implement gate of the first Feature session after this ships; and in this session's Test phase, on a worked example | NEED-01 |
| OUT-02 | Endpoints in the design's API contract compared with the built OpenAPI spec (method, path, request, response, error cases) | Every mismatch either fixed or listed as a variation; 0 unlisted mismatches | In this session's Test phase, on a worked backend example; then at the first backend Implement gate after this ships | NEED-02 |
| OUT-03 | Variations raised at an Implement gate that, after Close, are reflected in the as-built docs or explicitly dropped by a user decision | 100% | At Close of the first Feature session after this ships that has a variation | NEED-03 |
| OUT-04 | Tests whose kind doesn't match the phase that owns it (a unit or component test first written in Test; an integration, UI or Playwright test written in Implement), and backend `DES-*` items with both a unit and a component test | 0 mismatched tests; 100% of backend `DES-*` items covered by both | At the Test gate of the first backend Feature session after this ships | NEED-04 |
| OUT-05 | Implement tasks that name their `DES-*`, follow the design's implementation order, and carry or hand on that `DES-*`'s check | 100% of tasks | At the Implement gate of the first Feature session after this ships | NEED-05 |
| OUT-06 | `task-executor` Plan mode run against a session with a `design/` folder and against a past session with a root `design.md`; the number of skills that write constructs | Resolves the design in both; exactly one construct writer | In this session's Test phase | NEED-06 |
| OUT-07 | Files outside a new layer's own home that change when the next layer's Implement guidance and artifact are added | None (files only) | When the first follow-up layer issue ships, checked against its diff | NEED-07 |

### Appetite and no-gos

- **Appetite:** to be agreed with the user (asked 2026-10-10).
- **No-gos:** see [Non-goals](index.md#non-goals).
