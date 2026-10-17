<!-- tier: full. The main doc (D12). Summarise and link; never restate a sub-doc's content. -->
# Define: Implement phase — an as-built artifact, the backend API artifact and the testing boundary

> Phase: Define | Started: 2026-10-10 | Status: Ready for the Define milestone gate
> Relates to: Issue #28 (primary, parent #22 Q11); #52 (folded in, closes with this session); follow-ups #57, #58, #59, #60, #61, #50 · Session history: [`log.md`](../log.md)

## Contents

- [Requirements](requirements.md): REQ-001 to REQ-020 live (16 Must, 4 Should); REQ-021 to REQ-026 deferred to #57, #58, #59, #60, #50 and #61
- [Framing](framing.md): the XY check (the user's reframe), symptoms, the anchor verdict (aligns), and the overlaps with ADR-004 D7/D8, the design's API contract, stack defaults, Close's fold-back, Test's method column, #52, `task-executor`, `post-hook-validator` and ADR-002
- [Problem](problem.md): context, NEED-01 to NEED-07 (four central, three supporting), evidence, impact, OUT-01 to OUT-07, appetite
- [Quality](quality.md): ISO/IEC 25010:2023 coverage, NFR measures, assumptions and dependencies
- [Diagrams](diagrams.md): **the as-is and to-be view of the problem**, the context diagram, the impact map and the traceability diagram

## Framing

- **Tier:** full. The work gives the Implement phase an artifact standard and its first layer's guidance, changes what every Feature session's Implement and Test phases own, feeds Close's fold-back, and touches `task-executor` and construct ownership. The user confirmed it (2026-10-10).
- **Verdict:** aligns with the project anchor. The deferred AI-agent layer (#59) may extend Scope and runs its own anchor check. See [framing.md](framing.md).

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

As agreed with the user (2026-10-10):

1. **The as-built record and variations:** [REQ-001](requirements.md#requirements) to [REQ-003](requirements.md#requirements).
2. **Raising variations at the Implement milestone:** [REQ-004](requirements.md#requirements), [REQ-005](requirements.md#requirements).
3. **Folding variations back at Close:** [REQ-006](requirements.md#requirements).
4. **The testing boundary:** [REQ-007](requirements.md#requirements) to [REQ-010](requirements.md#requirements), plus [REQ-016](requirements.md#requirements).
5. **Backend, the first layer** (an OpenAPI spec rendered with Scalar, checked against the design; an established stack wins): [REQ-011](requirements.md#requirements) to [REQ-013](requirements.md#requirements).
6. **A layer plug-in contract for Implement:** [REQ-014](requirements.md#requirements).
7. **Tasks derived from the design** (#52): [REQ-015](requirements.md#requirements), [REQ-016](requirements.md#requirements).
8. **`task-executor` in step with the lifecycle, with one construct owner:** [REQ-017](requirements.md#requirements) to [REQ-019](requirements.md#requirements).
9. **Past sessions stay valid:** [REQ-020](requirements.md#requirements).

### Non-goals

- **Frontend, database and AI-agent Implement guidance and artifacts:** #57 (pairs with #46), #58 (pairs with #48) and #59 (with its own Design standard and anchor check). Frontend's component inventory with screenshots is only an example for #57.
- **Non-OpenAPI backend API artifacts** (GraphQL, gRPC): #60.
- **Infrastructure Implement guidance:** added to #50's scope. Infrastructure is a Design solution kind, not a layer.
- **The problem visual as part of Define's standard:** #61. This session has one, but doesn't change the standard.
- **Implement sending variations upstream itself**, or editing frozen `define/` or `design/` artifacts. Variations are recorded and raised. Close folds them back.
- **Integration, UI and Playwright testing standards in depth.** This session states the boundary; how Test does that testing isn't redesigned here.
- **Layer design standards** (#46, #47, #48). This session checks against `design/backend.md` if #47 has shipped, and against `design/solution.md` and the backend `DES-*` items if not.
- **The fallback when a layer has no Implement guidance.** Design decides it; it's a candidate solution in [framing.md](framing.md).
- **Migrating past sessions' artifacts.**
- **Mandating a backend stack.** An established stack always wins.

## Constraints

- **Variations are recorded and raised, never sent upstream by Implement** (user decision). Only Close folds them back into the as-built docs.
- **The testing boundary** (user decision):
  - Implement owns unit and component tests, and backend always has both.
  - Test owns integration, UI and Playwright tests. A harness test that runs real hooks and scripts together counts as integration.
  - Inspection stays a valid Test-owned method for requirements about documents or instructions.
  - A `VER-*` row may cite Implement's tests as supporting evidence only, and each `REQ-*` needs at least one Test-owned `VER-*`. Unit-only verification is ruled out.
- **The backend artifact is an OpenAPI spec rendered with Scalar, and only that, in this session** (user decision). Other API description formats are #60.
- **One home per layer (ADR-004 D7):** backend guidance goes in `skills/backend/` (`reference/implement.md`, plus `SKILL.md` unless #47 lands first). No stub folders for other layers.
- **Single responsibility per skill or file** (from #28).
- **Stack independence (ADR-004 D10):** build on a repo's established backend stack. Use `skills/design/reference/stack-defaults.md` only where none exists, and link to it rather than restate it.
- **The phase-agent contract stays:** Implement isn't conversational, writes only its artifact plus code and tests, never writes `log.md`, and commits one task at a time.
- **Traceability stays:** `REQ → DES → task → VER`, and `check-traceability.sh` keeps working.
- **Construct ownership follows ADR-004 D8** (Close adds the constructs a session built), unless it's revisited in Design with an ADR.
- **Established methods only** (anchor non-goal): OpenAPI for the API description, and the established unit, component and integration split.
- **This session's own Implement** runs before the new standard exists, so it uses the current `agents/implement.md`.
- **Appetite:** one working session (see [problem.md](problem.md#appetite-and-no-gos)).

## Open questions

All questions resolved.
- What counts as Test-owned for REQ-009 (option a): harness tests count as integration, and inspection is valid for document requirements.
- #52 is closed by this session's PR (`Closes #52`).
