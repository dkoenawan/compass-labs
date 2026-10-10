<!-- tier: full -->
# Framing: Design phase structure, with layered design skills and visual deltas

> Part of [index](index.md) · Define

## Problem checks

### Solution-first (XY)

- **Need behind the request:** #27 asks for "a design skill and standard doc" and #39 asks for "BPMN 2.0 and architecture views with a delta". The brief adds a classification step, a whole-system design followed by per-layer sub-skills, stack defaults, and merging `plan` into Design. Behind these requests are four needs, confirmed by the user:
  - the Design-gate approver can see how the design fits the process and project, and what is new, changed, deprecated or unchanged (NEED-01);
  - each significant choice, per layer, is made explicitly with its options, pros and cons (NEED-02);
  - Implement and Test get a design they can break into tasks and test components without re-deciding the solution (NEED-03);
  - maintainers have one design path, not two overlapping ones (NEED-04).

  Two further needs came from the user's Define-gate feedback:
  - prior knowledge comes from current project docs, not past session folders (NEED-05);
  - every component is simple and needed (NEED-06).

  The user named the principles (SOLID, YAGNI, KISS) and the source rule (project docs, never `docs/sessions/**`) directly. Both are confirmed as the need itself, not as candidate fixes.
- **Outcome:** the specific solutions were moved to Candidate solutions. The user asked for the classification step and the whole-system → per-layer structure to be recorded as **stakeholder-supplied candidate solutions and constraints that Design must address but may shape**. Retiring `plan` into Design and the per-layer home shared with #28 are confirmed user decisions, recorded in [Constraints](index.md#constraints).

**Candidate solutions:**
- A first step that classifies the solution kind: three-tier application, process/workflow, infrastructure, or plugin/tooling (from the brief; also a constraint, see index). The user refined it to one primary kind plus a checklist of the areas that might be in scope.
- For a three-tier application, a whole-system design followed by frontend, backend and database sub-skills (from the brief; also a constraint).
- BPMN 2.0 for process designs; architecture and infrastructure views, such as C4, for application designs; a separate format for frontend (from #39).
- A version-controlled visual source in `assets/` next to a rendered file (from #39; the user fixed the rendering rule as a constraint).
- An explicit current → new delta that marks elements new, changed, deprecated or unchanged (from #39).
- ADRs inline in the design doc or linked (an open question on #27, left to Design).
- The workflow JSON declares which visual standard each kind uses, as the `framing` block does today (an open question on #39, left to Design).
- A `design/` folder artifact, like `define/` (raised during framing; left to Design).
- ADRs kept grouped in the registry (`docs/registry/decisions/`) and linked from the design, rather than written inline. The user leans this way; Design decides.
- Giving the Design agent Bash so it can render SVGs itself (left to Design; see index Open questions).

### Symptom and cause

- **Observed symptoms:**
  - The Design template has five thin sections: Approach, a DES table, Decisions, Risks and Open questions [observed: `skills/session/templates/design.md`].
  - #23's design had to invent sections the template lacks: a visual overview, "What's new, changed, superseded and unchanged", and "Current vs new standards" [observed: `docs/sessions/archive/2026-09-25-define-phase-depth/design.md`].
  - Reviewers can't see fit or delta from prose and tables alone [observed: #39].
  - `plan` produces its own spec beside the session's design [observed: `skills/plan/SKILL.md`].
- **Cause:**
  - No Design skill or standard exists. The Design agent has only the template and a `TODO (#27)` [observed: `agents/design.md`].
  - `plan` predates the session lifecycle, and its split into requirements and design was left for #26/#27 [observed: #22 design, "Retire / redirect `plan`" row].
  - Whether the missing standard fully explains the ad-hoc sections, rather than reviewer preference, is **assumed**.

## Anchor

- **State:** complete. The root `README.md` has one marker pair; Vision, Mission, Scope and Non-goals are all present and non-empty; README line 3 links to the anchor instead of restating it. No conflicting restatement was found.
- **Verdict:** aligns
- **Rests on:**
  - Scope: "Standards for each session artifact, by session type and depth tier." (a Design standard is one of these)
  - Scope: "Supporting skills: scaffolding, planning, codebase exploration, documentation, architecture decisions, task execution, brand design." (planning moves into Design; the capability stays)
  - Scope: "Works in any repository, independent of tech stack." The stack defaults, including Terraform for infrastructure, are **defaults, not mandates**: they apply only where a repo has no established stack, and an existing repo's stack wins (user decision, Q3). So the work stays stack-independent.
  - Scope: "Supporting skills: … brand design." Delegating visual UI design to Claude Design doesn't remove `brand-designer` in this session; its retirement is deferred (REQ-034). So this scope line still holds today. The follow-up that retires `brand-designer` must run its own anchor check and will probably need to *extend* the anchor's Scope, that is, change the line.
  - Mission: "Diátaxis for documentation". Taking prior knowledge only from the Diátaxis docs that Close folds sessions into, never from past session folders (REQ-035), relies on that framework rather than working around it. The fallback for a repo with no docs (REQ-036) keeps "Works in any repository" true.
  - Non-goal: "Creating new methods where an established one exists." The principles check (REQ-037, REQ-038) uses established principles (KISS, YAGNI, SOLID) and invents none. Non-goal: "Applying a framework where it doesn't fit." SOLID applies only to software elements; KISS and YAGNI apply everywhere.
  - Non-goal: "A runtime, framework or hosted service." The Claude Design handoff (REQ-033) passes documents to an external service; compass-labs doesn't host or run one.
  - Mission: "C4 for architecture". Non-goal: "Creating new methods where an established one exists." Visual notations are chosen from established ones (C4, BPMN 2.0).
  - Non-goal: "Applying a framework where it doesn't fit." Classification picks the notation and depth by solution kind instead of forcing one layout on every design.

### Anchor update

- **Action:** none
- **Elements:** none
- **Agreed text:** none

## Overlaps

- **Overlap, `skills/plan/`:**
  - It already designs a feature from DB → Backend → Frontend. It covers a registry read, adaptive depth, tradeoff surfacing, Prisma models, CQRS naming, API shapes, routes, implementation order and registry construct stubs.
  - The user decided to retire it into Design (REQ-021, REQ-022).
- **Overlap, #28 (Implement phase: backend/frontend/database/infra/ai-agent skills):**
  - It covers the same layers as the per-layer design sub-skills.
  - The user decided that, per layer, the design sub-skill and #28's implement skill share one structure (REQ-006).
- **Overlap, `skills/bootstrap-new-project/` and the README's `bootstrap-new-project` section:**
  - These already state a default stack (React + Vite + TypeScript + Material-UI, Node.js + TypeScript + Prisma, PostgreSQL).
  - The Design stack defaults must not drift from them (REQ-010).
  - Bootstrap's Vite and Material-UI choices are superseded as a *visual* concern by the Claude Design constraint. The frontend default covers components and functionality only.
- **Overlap, `skills/brand-designer/`** (and `docs/explanation/brand-designer/`):
  - It generates brand guidelines, CSS custom properties and Tailwind config, which is visual UI design.
  - The user decided visual UI design is delegated to Claude Design, and this plugin shouldn't manage it.
  - The Design path gets only a handoff to Claude Design (REQ-033). Retiring or redirecting `brand-designer`, as `plan` is being retired, is **deferred** to #53 (REQ-034).
  - Frontend sub-issue #46 inherits the split: components and functionality in #46; visual design in Claude Design.
- **Interaction, `plan`'s capabilities vs REQ-035:**
  - `plan`'s "registry read before designing" (Phase 0) reads `docs/registry/index.md`, which is project documentation, so carrying it over (REQ-022) is consistent with REQ-035. Its Known-Gaps explore goes docs first, then code, and is also consistent.
  - `plan`'s registry construct stubs write `planned_in: docs/sessions/...`, a pointer from the docs back into a session folder. The carry-over must not let Design follow such pointers into past sessions, and ADR-003 already keeps session IDs out of as-built docs. Design decides what replaces the field.
- **Interaction, #45** (Close doesn't fold into Diátaxis when those trees are missing): in such a repo nothing reaches the docs, so REQ-035 finds no prior knowledge. REQ-036's fallback covers this, but the prior knowledge is lost until #45 is fixed. This is a dependency, not a conflict.
- **Consistent, phase-agent contract rule 4** ("read your own artifact and the session's other frozen artifacts"): it already means the current session only. REQ-035 makes the exclusion of past sessions explicit for Design.
- **Related, #20** (cloud-agnostic Terraform scaffolding) and **#50** (infrastructure in-depth path): the Terraform infrastructure default (REQ-008, REQ-010) must agree with #20's scaffolding and be the default #50 designs for.
- **Conflict, ADR-003's "Renderable" NFR:**
  - The NFR says every diagram is a Mermaid type GitHub renders. BPMN 2.0 (#39) isn't Mermaid.
  - ADR-003 scopes that NFR to Define's diagrams. The user's rendering constraint (Mermaid where possible, plus a committed SVG next to any non-Mermaid source) extends it to Design. Design should record this in a new ADR, or in an amendment to ADR-003.
- **Refinement, not conflict, ADR-002's "Bounded" NFR:**
  - `assets/` already takes non-Markdown files, so visual sources and SVGs fit.
  - A `design/` folder artifact would refine ADR-002 the way ADR-003 did for `define/`.
- **ADR-001 (Proposed)** lists `plan` under Affects. Retiring `plan` makes that line stale. That is a note for Design, not a conflict.
- **Construct registry:** empty (`construct_count: 0`). No construct overlaps were found.
