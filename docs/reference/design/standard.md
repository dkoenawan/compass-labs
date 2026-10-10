# Design: the standard, its gate and its limits

> → Concepts: [Design overview](../../explanation/design/overview.md) · → [Session workflow and artifacts](../session/workflow-and-artifacts.md#the-design-folder)
> Origin: #27

The procedure itself is in [`skills/design/SKILL.md`](../../../skills/design/SKILL.md). This page lists the facts other docs, tools and sessions rely on, and links to the skill files that define them. The `design/` folder's file set and ownership are in the [session reference](../session/workflow-and-artifacts.md#the-design-folder).

## Procedure

1. **Prior knowledge.** Read the project docs, the code and the current session's folder, and record what was read under "Prior knowledge" in `design/index.md`.
2. **Classify and check scope.** Name one primary kind with a one-line reason citing the requirements, and mark each area of the scope checklist in or out with a reason. The user confirms both before any further design.
3. **Design in depth.** Follow the kind's in-depth path if it has one. Otherwise cover the solution in the all-kinds sections and name the kind's follow-up issue under Open questions. Apply the stack rule per stack area in scope. The user chooses at every significant choice.
4. **Visuals and delta.** Draw the context view and other visuals in the catalogue's notation, captioned and delta-styled, and write the delta list.
5. **Principles and coverage.** Fill in the principles check, list rejected items under YAGNI, and run the coverage self-check. The user resolves every *traded off* mark.

Design has no depth tier of its own. Its depth follows the tier and scope Define confirmed: an area no live requirement touches is marked *unchanged* and gets no detailed design, and no Design tier is recorded.

## Prior knowledge

| Source | Read? |
|---|---|
| `docs/explanation/`, `docs/reference/`, `docs/registry/` (index, patterns, ADRs) | yes |
| The repository's code and manifests | yes |
| The current session's frozen `define/` output and its `log.md` | yes |
| Any other folder under `docs/sessions/`, including `docs/sessions/archive/` | **never**, by any tool, Bash included |
| A construct's `planned_in` pointer into `docs/sessions/` | ignored; the construct's doc and the code are used instead |

With no project documentation, the design records: "No project documentation found; designed from the Define output and the code."

## Kind catalogue

| Kind | In-depth path | Follow-up |
|---|---|---|
| Three-tier application | [`kinds/three-tier.md`](../../../skills/design/kinds/three-tier.md) | — |
| Process/workflow | none yet | #49 |
| Infrastructure | none yet | #50 |
| Plugin/tooling | none yet | #51 |
| Other | all-kinds sections only | — |

Layer standards without a home yet: frontend #46, backend #47, database #48. In a design, a follow-up is written as the full `dkoenawan/compass-labs#nn` reference so it resolves to this plugin, not to the repo being designed.

**Adding a kind** means adding exactly three things: `kinds/{kind}.md`, its rows in [`reference/notations.md`](../../../skills/design/reference/notations.md), and its catalogue row. The procedure, the classification step, the scope checklist and the all-kinds sections don't change.

## Three-tier path

- `design/solution.md` holds the **whole-system design**: each of frontend, backend and database *changing* or *unchanged*, the contracts between adjacent changing layers (frontend ↔ backend endpoints and shapes, backend ↔ database entities and constraints), a C4 L1 context view and a C4 L2 container view.
- The user approves the whole-system design **before any layer file is written**. A later contract change goes back to the user the same way.
- Each changing layer then gets `design/{layer}.md`, to the standard in its **per-layer home** `skills/{layer}/`. That home holds both the layer's design standard (`reference/design.md`) and its Implement skill (`reference/implement.md`).
- A layer standard supplies its inputs from the whole-system design, its required sections and its output, and is added without changing the Design standard.

## All-kinds sections of `design/index.md`

| Section | Required content | Checked at the gate |
|---|---|---|
| Classification | Primary kind and reason, as confirmed | yes |
| Scope checklist | Each area in or out, with a reason, as confirmed | yes |
| Context view | The solution in the project and in the process it serves, with delta styling | yes |
| Delta list | One row per touched element, exactly one status each, and its `DES-*` | yes |
| Components (DES) | The handoff table below | — |
| Decisions | Each significant choice: two or more options, pros and cons, the user's choice and reason | — |
| Principles check | Per `DES-*` item and choice, plus "Rejected under YAGNI" | — |
| Risks | Risk and mitigation | — |
| Open questions | Unresolved items, and the follow-up issue for any kind or area without a path | — |

## Components (DES) table

Columns, in this order:

| Column | Holds |
|---|---|
| ID | `DES-*`, numbered in sequence, never reused, always first |
| Component | The component or layer and where it lives |
| Covers | The live `REQ-*` it delivers |
| Result | What Implement must produce |
| Check | How to tell the result is done |
| Depends on | `DES-*` items to build first, or `—` |

Under the table: the implementation order the dependencies imply (acyclic), and a coverage line confirming every live `REQ-*` appears in at least one Covers cell.

## Significant choices and principles

- A **significant choice** is one a reasonable reviewer could have made differently, and that changes what Implement builds. It needs at least two options with at least one pro and one con each, and the user chooses. The agent never picks one alone.
- An existing ADR is linked, not re-decided. A new architecture-level decision is flagged **"ADR"** in the design, and Close writes it into `docs/registry/decisions/`. Design never writes ADR files.
- **Principles check marks:** *met*, *traded off* (with a reason, resolved by the user), or *n/a* (with a reason, SOLID only).

| Principle | Applies to |
|---|---|
| KISS | every element of every kind |
| YAGNI | every element of every kind. Anything no live `REQ-*` needs is listed under "Rejected under YAGNI" and not designed |
| SOLID (all five) | software elements: code, modules, services, skills, agents, scripts, workflow definitions. *n/a* with a reason otherwise |

## Stack rule

The single source is [`skills/design/reference/stack-defaults.md`](../../../skills/design/reference/stack-defaults.md). Every other plugin file that names a default stack links to it.

| Stack area | Default, used only when no established stack is found |
|---|---|
| Frontend | React + TypeScript (Vite in the scaffold) |
| Backend | Node.js + TypeScript, CQRS, OpenAPI rendered with Scalar |
| Database | PostgreSQL through Prisma, all schema changes as Prisma migrations |
| Infrastructure | Terraform |

An established stack, detected from the repo's files, always wins. Design never proposes replacing it unless the user asks. A partly established area keeps its stack and fills the gap in its own ecosystem. The design states what it detected per area.

## Visuals

| Rule | Value |
|---|---|
| Notation | From the [notation catalogue](../../../skills/design/reference/notations.md#catalogue): C4 for three-tier, plugin/tooling and infrastructure (deployment); ER, component-hierarchy and sequence views for layers; BPMN 2.0 for process/workflow |
| C4 form | Mermaid `flowchart` with C4 abstractions, one C4 level per diagram. Mermaid's `C4Context` is not used |
| Caption | One italic line above each visual, naming the notation and, for C4, the level |
| Delta styling | Four classDefs (`new`, `changed`, `deprecated`, `unchanged`) **and** a `[status]` label suffix, so it reads without colour. Diagram types that can't carry classDefs use the suffix only |
| Source of truth | The delta list. Every visual matches it |
| Non-Mermaid source | Editable source and a rendered SVG with the same base name, side by side in the session's `assets/`. The design embeds the SVG and links the source |
| Render target | **0** visuals in a design that show as source text instead of a diagram on github.com, counted by hand at the Design gate |

## Claude Design handoff

Written as `design/ui-handoff.md` only when visual UI design is in scope:

- **Handoff:** each screen and component needing visual design, the `REQ-*` each serves, every state (loading, empty, saved, error, disabled, …), and behaviour constraints from the frontend design.
- **Never** any colour, font, typeface, size or spacing value.
- **Returned design:** the HTML zip export as-is at `assets/ui-design.zip` (never unzipped into the repo), one embedded PNG per screen at `assets/ui-{screen}.png`, and the Claude Design project link if there is one. The slot can be filled later in the session.

## Design gate

- The gate message shows, or links directly to, `design/index.md#context-view` and `#delta-list` before the approve, adjust and rethink options.
- Before the milestone, the orchestrator runs `bash skills/session/scripts/check-design.sh {session-dir}`:

| Situation | Output | Exit |
|---|---|---|
| `design/index.md` has `## Classification`, `## Scope checklist`, `## Context view`, `## Delta list` | `check-design: ok (…)` | 0 |
| Any of those level-2 headings missing | one `check-design: {section} missing` line each, e.g. `delta list missing` | 1, milestone refused |
| Only a root `design.md` (past session) | `check-design: legacy layout: no check` | 0 |
| Neither exists | `check-design: design not found: …` | 1 |

Past sessions with a root `design.md` are never migrated. The guard hook, the gate and `check-traceability.sh` treat them exactly as before the `design/` folder existed.

## Design agent tools

`agents/design.md` has Read, Glob, Grep, Write, Edit and Bash. Bash is limited by the agent's own rule, not the hook:

- **Allowed:** render non-Mermaid sources to SVG, check Mermaid parses, screenshot a Claude Design export.
- **Outputs:** the session's `assets/` or a `mktemp -d` directory outside the repo only.
- **Never:** `git`, writing, moving or deleting other files, or reading past session folders.

The commands are in [`reference/notations.md`](../../../skills/design/reference/notations.md#non-mermaid-route), so a user without the tooling can run them by hand.
