<!-- tier: full. The main doc (D12). -->
# Define: Design phase structure, with layered design skills and visual deltas

> Phase: Define | Started: 2026-09-28 | Status: Draft
> Relates to: Issue #27 (primary), #39 (linked); sub-issues #46, #47, #48; follow-ups #49–#53 · Session history: [`log.md`](../log.md)

## Contents

- [Requirements](requirements.md): REQ-001 to REQ-024, REQ-032, REQ-033 and REQ-035 to REQ-038 live; REQ-025 to REQ-031 and REQ-034 deferred
- [Framing](framing.md): the XY and symptom checks, the anchor verdict (aligns), overlaps and interactions with `plan`, `brand-designer`, #28, #20, #45, `bootstrap-new-project`, ADR-002 and ADR-003
- [Problem](problem.md): context, NEED-01 to NEED-06, evidence, impact, OUT-01 to OUT-06, appetite
- [Quality](quality.md): ISO/IEC 25010:2023 coverage, NFR measures, assumptions and dependencies
- [Diagrams](diagrams.md): impact map, context diagram, traceability, as-is and to-be

## Framing

- **Tier:** full. The work adds a phase capability with per-layer extension points, changes the process every Feature session follows, retires `plan`, touches the Design gate, and splits off sub-issues. The user confirmed it.
- **Verdict:** aligns with the project anchor. The stack defaults, Terraform included, yield to a repo's established stack. `brand-designer` stays in this session, so the "brand design" Scope line still holds; its retirement (REQ-034) must run its own anchor check. See [framing.md](framing.md).

## Problem statement

Design is the thinnest conversational phase. It has five template sections, no skill, no visuals or delta, and no per-layer depth. Meanwhile `plan` produces a second, differently shaped design, so reviewers reconstruct what changes and later phases may re-decide the solution.
- Needs: NEED-01 (approver sees fit and delta), NEED-02 (depth by solution kind and scope, explicit per-layer choices), NEED-03 (Implement and Test build what was approved), NEED-04 (one extensible design path), NEED-05 (prior knowledge from current docs, never past sessions), NEED-06 (every component simple and needed).
- Outcomes: OUT-01 to OUT-06.

Each claim is tagged with its evidence in [problem.md](problem.md).

## Scope

1. **Classification:** one primary solution kind, plus a scope checklist of every area that might be in scope: [REQ-001](requirements.md#requirements), [REQ-002](requirements.md#requirements).
2. **An extensible framework:** a contract for adding solution kinds and layers, and one per-layer home shared with #28: [REQ-003](requirements.md#requirements), [REQ-005](requirements.md#requirements), [REQ-006](requirements.md#requirements).
3. **Depth matches Define:** the design is as deep as Define's tier and scope, with no Design tiers of its own: [REQ-032](requirements.md#requirements).
4. **Three-tier depth:** a whole-system design approved before layer detail, with written options for every significant choice: [REQ-004](requirements.md#requirements), [REQ-007](requirements.md#requirements).
5. **Stack defaults** (frontend, backend, database, and Terraform for infrastructure) that yield to an established stack and are stated once: [REQ-008](requirements.md#requirements) to [REQ-010](requirements.md#requirements).
6. **Visuals and delta (#39):** a context view, a delta status per element, notation by kind, rendering on GitHub, and a documented render route for non-Mermaid sources: [REQ-011](requirements.md#requirements) to [REQ-015](requirements.md#requirements).
7. **The Design gate uses the visuals:** [REQ-016](requirements.md#requirements), [REQ-017](requirements.md#requirements).
8. **The Design → Implement handoff:** coverage, results and checks, and dependency order: [REQ-018](requirements.md#requirements) to [REQ-020](requirements.md#requirements).
9. **The handoff to Claude Design** for visual UI design: [REQ-033](requirements.md#requirements).
10. **Retiring `plan` into Design:** [REQ-021](requirements.md#requirements) to [REQ-023](requirements.md#requirements).
11. **Past sessions stay valid:** [REQ-024](requirements.md#requirements). This is about tools treating old artifacts the same; item 12 is about where Design gets its knowledge.
12. **Prior knowledge comes from the project docs, never from past session folders**, with a fallback when a repo has no docs: [REQ-035](requirements.md#requirements), [REQ-036](requirements.md#requirements).
13. **Design principles:** a KISS/YAGNI check on every element (plus SOLID on software), and rejection of anything no requirement needs: [REQ-037](requirements.md#requirements), [REQ-038](requirements.md#requirements).

### Non-goals

- **The frontend, backend and database in-depth designs.** These are sub-issues #46, #47 and #48 (deferred REQ-025 to REQ-027). This session delivers the layer framework they plug into. #46 covers components and functionality only.
- **Changes to the Implement phase.** This session defines only the handoff; Implement consuming it is #52 (deferred REQ-028).
- **In-depth paths for the process/workflow, infrastructure and plugin/tooling kinds.** These are #49, #50 and #51 (deferred REQ-029 to REQ-031). Classification recognises them now.
- **Visual UI design in this plugin.** It is delegated to Claude Design. Retiring or redirecting `brand-designer` is deferred to #53 (REQ-034).
- **Mandating a tech stack.** The stack defaults never override a repo's established stack.
- **Migrating past sessions' design artifacts.** They stay as written (REQ-024).
- **Changing the Define phase or its standards.**

## Constraints

- **Stakeholder-supplied structure (user decision, Q2):** Design must address a classification step first, and for three-tier applications a whole-system design followed by per-layer frontend, backend and database designs. Design may shape how. Classification gives one primary kind plus a scope checklist (OQ2).
- **Stack defaults, not mandates (Q3):**
  - frontend: React + TypeScript and its matching component ecosystem;
  - backend: Node.js, CQRS, Scalar API docs;
  - database: Postgres managed through Prisma;
  - infrastructure: **Terraform** (new constraint; related #20, #50).

  They apply only where a repo has no established stack.
- **Visual UI design is delegated to Claude Design (new constraint):**
  - The frontend layer covers components and functionality (React + TS), not visual design.
  - The Design path needs only a handoff between this repo's sessions and Claude Design.
- **Design depth matches Define's scope and tier (OQ4).** There are no separate Design tiers.
- **`plan` is retired into Design (Q6):** its useful content is absorbed, and `plan` is removed or redirects.
- **Per layer, the design sub-skill and #28's Implement skill share one structure (Q6).**
- **Rendering (Q7):** every visual renders natively on GitHub. Use Mermaid where possible; for any non-Mermaid source (for example BPMN XML), commit a rendered SVG next to it in the session's `assets/`. Where Design can't render a source itself, a documented route is enough (OQ1).
- **Prior knowledge from the docs only (Define-gate feedback):**
  - Design reads earlier designs, patterns and decisions only from the project's Diátaxis docs (`docs/explanation`, `docs/reference`, `docs/registry` and its ADRs), plus the code and its own session.
  - It never reads `docs/sessions/**` outside the current session, archive included.
  - `plan`'s registry read, carried over by REQ-022, fits this rule.
- **Design principles, always (Define-gate feedback):**
  - KISS and YAGNI apply to every solution kind.
  - SOLID applies as well wherever the design is software.
- **The phase-agent contract stays:** the Design agent asks only through the orchestrator, writes only its own artifact, and never writes `log.md`.
- **Traceability stays:** `REQ → DES → task → VER` and `check-traceability.sh` keep working.
- **Portable:** the Design path must work in a repo with no registry, no ADRs and no `docs/` layout, like framing.
- **Appetite:** two focused days (see [problem.md](problem.md#appetite-and-no-gos)).
- **This session's own Design** runs before the new Design path exists, so it uses the current template. REQ-024 keeps the new gate check off it.

## Open questions

1. **Bash for the Design agent.** The user believes the Design agent has Bash, but `agents/design.md` grants only Read, Glob, Grep, Write and Edit. Whether to grant Bash, for example to render SVGs, is a design choice. Either way, REQ-015 needs only a documented render route this session.
2. **Left to Design** (OQ5):
   - whether ADRs are written inline or linked (the user leans towards keeping them grouped in the registry, `docs/registry/decisions/`, and linking them);
   - where each kind's notation is declared (the agent, the standard or the workflow JSON);
   - how the delta is encoded;
   - whether the design artifact becomes a `design/` folder;
   - where the stack defaults' single source lives (REQ-010).
3. **The form of the returned visual design (REQ-033).** Claude Design hands back a visual design; is it a link, an exported image in `assets/`, or both? Left to Design, within the rendering constraint.
4. **Other phases and past sessions.** REQ-035 governs Design only, as asked. This Define itself cited archived sessions (#22, #23) as evidence for the problem statement. Should the same rule apply to Define and the other phases? That's for the user to decide; it isn't part of this session unless they widen it.
5. **Follow-up for REQ-034:** resolved. Retiring or redirecting `brand-designer` is tracked in #53, which also runs the anchor check for the "brand design" Scope line.
