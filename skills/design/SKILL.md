---
name: design
description: The Design standard for a Feature session's Design phase. It classifies the solution, checks scope, and produces the design/ folder (context view, delta list, DES items with result, check and dependencies, decisions, principles check), following an in-depth path per solution kind. Preloaded by the Design agent.
---

# Design standard

This is the standard for a Feature session's Design phase. It turns the frozen Define output into a design that a reviewer can approve at a glance and that Implement can build from. This file holds what every solution kind shares. A kind with more depth has its own file under `kinds/`, and the other material is in the on-demand files listed at the end.

**Where the design goes.** A new session writes a `design/` folder, from `${CLAUDE_PLUGIN_ROOT}/skills/session/templates/design/`:

| File | Holds | When |
|---|---|---|
| `design/index.md` | The main doc: every all-kinds section below | always |
| `design/solution.md` | The kind's in-depth design (for three-tier, the whole-system design) | when the kind has an in-depth path |
| `design/frontend.md`, `design/backend.md`, `design/database.md` | Layer designs, to that layer's standard | when the layer changes and its standard exists |
| `design/ui-handoff.md` | The Claude Design handoff and the returned visual design | when visual UI design is in scope |

A past session that has a root `design.md` keeps it. That file is never migrated, it follows the old `templates/design.md`, and this standard's new gate check doesn't apply to it.

## Procedure

Work through these steps in order. Each step that asks the user something returns `needs_input` (the phase-agent contract) and waits for the answer.

1. **Read prior knowledge.** Read only the sources the [prior-knowledge rule](#prior-knowledge) allows, and record what you read and what you didn't.
2. **Classify the solution and check scope.** Name the solution's **primary kind** with a one-line reason that cites the requirements, choosing from the [kind catalogue](#kind-catalogue). Then write the **scope checklist**: each area (frontend, backend, database, infrastructure, process/workflow, plugin/tooling, visual UI design, and any other the requirements touch) marked *in* or *out*, each with a reason. **The user confirms both** before you design anything further.
3. **Design in depth.**
   - If the primary kind has an in-depth path, follow its `kinds/{kind}.md`. It says what goes in `design/solution.md` and whether layer files follow.
   - If it has none, cover the solution, and every in-scope area that has no path, in the all-kinds sections below. Name the kind's or area's follow-up issue (from the catalogue) under Open questions.
   - For each in-scope stack area, use [`reference/stack-defaults.md`](reference/stack-defaults.md). Design for an established stack if the repository has one, and propose the default only if it doesn't.
   - Each significant choice follows the [significant-choices rule](#significant-choices-and-principles-check): the user chooses.
4. **Draw the visuals and the delta.** Draw the context view, and any other visual, in the notation [`reference/notations.md`](reference/notations.md) gives for the kind. Caption each one and style its delta. Write the delta list.
5. **Check the principles and coverage.** Fill in the principles check for every `DES-*` item and every significant choice. List anything no live `REQ-*` needs under "Rejected under YAGNI". Run the [coverage self-check](#design--implement-handoff). Any principle marked *traded off* goes to the user to resolve.
6. **Return `done`** when the user has answered every question and the design is complete. The Design gate shows the context view and the delta list.

### Depth follows Define

Design has **no depth tiers of its own**. Its depth follows the tier and scope that Define confirmed (`define/index.md`) and the frozen live requirements. Design only what those requirements touch:

- An area or layer that no live requirement changes is marked *unchanged* and gets no detailed design.
- A short-tier Define output with two backend requirements gives a design whose only layer design is the backend's.
- Don't record a Design tier. Name Define's tier where depth needs explaining.

## Prior knowledge

Design builds on what the project already knows. Read prior knowledge **only** from these sources:

- **The project documentation:** `docs/explanation/`, `docs/reference/` and `docs/registry/` (its `index.md`, `patterns.md` and the ADRs in `decisions/`).
- **The repository's code and manifests:** the established stack, existing modules, and the constructs the design extends.
- **The current session's folder:** the frozen `define/` output and this session's own `log.md`.

**Never read a past session folder.** That means anything under `docs/sessions/` other than the current session, `docs/sessions/archive/` included. Use no tool to reach one: no Read, Glob or Grep, and no Bash `cat`, `grep -r` or `find` that descends into `docs/sessions/`. Past session folders hold drafts, abandoned options and decisions that were later reversed. What a past session actually shipped was folded back into the project documentation at Close, so read it there. If a registry construct has a `planned_in` pointer into `docs/sessions/`, ignore the pointer and use the construct's own doc and the code.

**Record what you read.** Under a "Prior knowledge" heading in `design/index.md`, list the docs and code you read, and the sources you deliberately didn't read (past sessions). Cite a doc wherever the design reuses something from it.

**With no project documentation** (no `docs/`, or none of the folders above), design from the frozen Define output and the code alone, and write this sentence in the Prior knowledge section:

> No project documentation found; designed from the Define output and the code.

## All-kinds sections

Every design has these sections in `design/index.md`, whatever its kind. The template has a heading for each, and the Design gate checks the first four.

| Section | What it holds |
|---|---|
| Classification | The primary kind and its one-line reason, as the user confirmed it |
| Scope checklist | Each area *in* or *out*, with a reason, as the user confirmed it |
| Context view | The solution within the project and within the process it serves (who uses it, what it touches, what depends on it), with delta styling |
| Delta list | One row per element the design touches, each with exactly one status (`new`, `changed`, `deprecated`, `unchanged`) and the `DES-*` it belongs to. It is the source of truth that every visual matches |
| Components (DES) | The `DES-*` table that Implement builds from (see [handoff](#design--implement-handoff)) |
| Decisions | Each significant choice, with its options, pros and cons, the user's choice and the reason |
| Principles check | KISS, YAGNI and SOLID marks per `DES-*` item and choice, plus the "Rejected under YAGNI" list |
| Risks | What could go wrong, and the mitigation |
| Open questions | What is still unresolved, including the follow-up issue for any kind or area without an in-depth path |

The kind's in-depth sections go in `design/solution.md`. They refine these sections and never replace them.

## Kind catalogue

Classify the solution as one primary kind. A solution that spans areas still has one primary kind, and the scope checklist covers the other areas.

| Kind | In-depth path | Typical signs in the requirements |
|---|---|---|
| Three-tier application | `kinds/three-tier.md` | A user interface, an API or service, and stored data, changing together |
| Process/workflow | none yet: dkoenawan/compass-labs#49 | Steps, hand-offs, approvals or roles change; little or no code |
| Infrastructure | none yet: dkoenawan/compass-labs#50 | Hosting, networking, deployment or cloud resources change |
| Plugin/tooling | none yet: dkoenawan/compass-labs#51 | Developer tooling, plugins, scripts, CLIs or agent skills |
| Other | none: the all-kinds sections only | Nothing above fits. Say why in the classification reason |

Areas inside a kind have their own follow-ups, for when they're in scope and their layer standard doesn't exist yet: frontend dkoenawan/compass-labs#46, backend dkoenawan/compass-labs#47, database dkoenawan/compass-labs#48.

When the primary kind, or an in-scope area, has no in-depth path, write every all-kinds section so that it covers that kind or area, and cite its follow-up issue under Open questions. Always write the follow-up as the full `dkoenawan/compass-labs#nn` reference, so it resolves to this plugin's issue rather than to an issue in the repository being designed.

### What a kind supplies

To give a kind an in-depth path, add these three things and nothing else:

1. **`kinds/{kind}.md`**: the kind's in-depth design. It lists the sections that go in `design/solution.md` and how they refine the all-kinds sections, any approval step inside the kind (for example, approving a whole-system design before any layer), whether the kind has layer files and their contract, and a worked example.
2. **Rows in [`reference/notations.md`](reference/notations.md)**: the notation for each of the kind's visuals, with its Mermaid form, or the non-Mermaid route if GitHub can't render it.
3. **This catalogue's row**: point the kind's In-depth path cell at its file, replacing the follow-up issue.

Adding a kind never changes the procedure, the classification step, the scope checklist or the all-kinds sections. If a kind seems to need one of those changed, raise it as a change to this standard instead.

## On-demand files

Read these only when the step that needs them comes up.

| File | Read it when |
|---|---|
| [`reference/notations.md`](reference/notations.md) | Drawing any visual: the notation for the kind, the delta styling, captions, and rendering (including non-Mermaid sources and Claude Design screenshots) |
| [`reference/stack-defaults.md`](reference/stack-defaults.md) | A stack area is in scope: detect an established stack, or propose the default |
