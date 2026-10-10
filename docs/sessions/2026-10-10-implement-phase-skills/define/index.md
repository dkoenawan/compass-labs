<!-- tier: full. The main doc (D12). Summarise and link; never restate a sub-doc's content. -->
# Define: Implement phase — an as-built artifact, the backend API artifact and the testing boundary

> Phase: Define | Started: 2026-10-10 | Status: Draft (revised problem statement and constraints awaiting agreement)
> Relates to: Issue #28 (primary, parent #22 Q11); #52 (folded in); related #47, #46, #48, #50 · Session history: [`log.md`](../log.md)

## Contents

- [Framing](framing.md): the XY check (the user's reframe), symptoms, the anchor verdict (aligns), and the overlaps with ADR-004 D7/D8, the design's API contract, stack defaults, Close's fold-back, Test's method column, #52, `task-executor`, `post-hook-validator` and ADR-002
- [Problem](problem.md): context, NEED-01 to NEED-07 (four central, three supporting), evidence, impact, OUT-01 to OUT-07, appetite (pending)
- [Diagrams](diagrams.md): **the as-is and to-be view of the problem** (phases, artifacts, the variation path, the backend API artifact and the two kinds of testing) and the context diagram; the impact map and traceability diagrams follow the requirements

`requirements.md` and `quality.md` follow once the problem statement and constraints are agreed.

## Framing

- **Tier:** full. The work gives the Implement phase an artifact standard and its first layer's guidance, changes what every Feature session's Implement and Test phases own, feeds Close's fold-back, and touches `task-executor` and construct ownership. The user confirmed it (2026-10-10).
- **Verdict:** aligns with the project anchor. The deferred AI-agent layer may extend Scope and must run its own anchor check. See [framing.md](framing.md).

## Problem statement

**Implement produces nothing reviewable besides code, so whether the build matches the design can't be checked, and design changes made while building never get back to Define or Design.** See the [as-is and to-be view](diagrams.md#as-is-and-to-be).
- Central needs:
  - NEED-01: an as-built record per `DES-*`, with variations.
  - NEED-02: the backend's built API, as an OpenAPI spec rendered with Scalar, checked against the design.
  - NEED-03: variations raised at the Implement gate and folded back by Close.
  - NEED-04: the testing boundary. Implement does unit and component tests; Test does integration, UI and Playwright.
- Supporting needs: NEED-05 (tasks from `DES-*`, #52), NEED-06 (`task-executor` in step), NEED-07 (later layers plug in by files).
- Outcomes: OUT-01 to OUT-07.

Each claim is tagged with its evidence in [problem.md](problem.md).

## Scope

Draft for agreement:

1. **The Implement artifact standard:** an as-built record for every `DES-*` (built as designed, deviated, or not built, each with a reason) and a list of the variations found while building. Its form, whether in `tasks.md` or a new file, is Design's choice.
2. **Raising variations at the Implement milestone:** the gate shows them for the user to decide on. Implement doesn't send them upstream itself.
3. **Folding variations back at Close:** Close reads Implement's artifact so the as-built docs match what was built. *Proposed in scope; see Open questions.*
4. **The testing boundary:**
   - Implement writes and runs unit and component tests, and backend always gets both.
   - Test runs integration, UI and Playwright tests.
   - Both phases' guidance says so.
5. **Backend, the first layer:** Implement guidance that produces an OpenAPI spec, rendered with Scalar, alongside the code, and checks it against the API in `design/`. A mismatch becomes a variation.
6. **A layer plug-in contract for Implement**, so each later layer adds its guidance and artifact by files alone, in its ADR-004 home.
7. **Tasks derived from the design** (#52, folded in): each task from a `DES-*`'s result, check and dependencies, in the design's implementation order.
8. **`task-executor` in step with the lifecycle:** it finds a session's design (`design/` folder or a past session's root `design.md`), and construct registration has a single owner, including what that means for `post-hook-validator`.
9. **Past sessions stay valid:** their `tasks.md`, root `design.md` and `verification.md` keep working.

### Non-goals

- **Frontend, database and AI-agent Implement guidance and artifacts.** Each becomes a sub-issue (see Open questions). Frontend's component inventory with screenshots is recorded only as an example for its issue. The AI-agent issue also needs a Design-side standard and its own anchor check.
- **Infrastructure Implement guidance.** Infrastructure is a solution kind in Design (#50), not a layer.
- **Implement sending variations upstream itself**, or editing frozen `define/` or `design/` artifacts. Variations are recorded and raised. Close folds them back.
- **Integration, UI and Playwright testing standards in depth.** This session states the boundary; how Test does that testing isn't redesigned here.
- **Layer design standards** (#46, #47, #48). This session checks against `design/backend.md` if #47 has shipped, and against `design/solution.md` and the backend `DES-*` items if not.
- **The fallback when a layer has no Implement guidance.** Design decides it; it's a candidate solution in [framing.md](framing.md).
- **Migrating past sessions' artifacts.**
- **Mandating a backend stack.** An established stack always wins.

## Constraints

Draft for agreement:

- **Variations are recorded and raised, never sent upstream by Implement** (user decision): Implement records each variation in its artifact and raises it at the Implement milestone. Only Close folds variations back into the as-built docs.
- **The testing boundary** (user decision): Implement owns unit and component tests, and backend always has both. Test owns integration, UI and Playwright tests.
- **The backend artifact is an OpenAPI spec rendered with Scalar**, produced alongside the code and checked against the API in `design/` (user decision). Where a repo's established backend doesn't use OpenAPI, the stack-independence rule applies (see Open questions).
- **One home per layer (ADR-004 D7):** backend guidance goes in `skills/backend/` (`reference/implement.md`, plus `SKILL.md` unless #47 lands first). No stub folders for other layers.
- **Single responsibility per skill or file** (from #28).
- **Stack independence (ADR-004 D10):** build on a repo's established backend stack. Use `skills/design/reference/stack-defaults.md` only where none exists, and link to it rather than restate it.
- **The phase-agent contract stays:** Implement isn't conversational, writes only its artifact plus code and tests, never writes `log.md`, and commits one task at a time.
- **Traceability stays:** `REQ → DES → task → VER`, and `check-traceability.sh` keeps working.
- **Construct ownership follows ADR-004 D8** (Close adds the constructs a session built), unless it's revisited in Design with an ADR.
- **Established methods only** (anchor non-goal): OpenAPI for the API description, and the established unit, component and integration split.
- **This session's own Implement** runs before the new standard exists, so it uses the current `agents/implement.md`.
- **Appetite:** pending (see Open questions).

## Open questions

1. **Agree the revised problem statement and constraints:** NEED-01 to NEED-07, OUT-01 to OUT-07, the scope and the constraints above, and the [as-is and to-be view](diagrams.md#as-is-and-to-be). Requirements are drafted only after that.
2. **Close's fold-back of variations (scope item 3):** is changing Close to read Implement's artifact in this session, or a follow-up? Without it, NEED-03 is met only up to the Implement gate.
3. **Backend without OpenAPI:** where a repo's established backend has no OpenAPI (for example GraphQL or gRPC), should the API artifact be that ecosystem's own schema (for example a GraphQL SDL or `.proto`), checked against the design the same way? Or does this session cover OpenAPI only, with the rest deferred?
4. **Unit tests as Test evidence:** may a `VER-*` row still cite an Implement-phase unit or component test as its evidence, or must every `VER-*` come from integration, UI or Playwright testing?
5. **Appetite:** how much effort is this session worth? For comparison, #27 was "two focused days".
6. **Sub-issues for the orchestrator to create** (each one links back to #28 and this session):
   - Frontend Implement guidance and artifact (for example a component inventory with screenshots), `skills/frontend/reference/implement.md`. Pairs with #46.
   - Database Implement guidance and artifact, `skills/database/reference/implement.md`. Pairs with #48.
   - AI-agent layer: design and Implement guidance for code in consuming repos that builds LLM agents. Needs its own anchor check.
   - Infrastructure Implement guidance: a new issue, or added to #50's scope?
7. **#52:** closed by this session's PR (`Closes #52`), as the user decided.
