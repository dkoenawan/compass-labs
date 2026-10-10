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
| Three-tier application | [`kinds/three-tier.md`](kinds/three-tier.md) | A user interface, an API or service, and stored data, changing together |
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

## Significant choices and principles check

### Significant choices

A choice is **significant** if a reasonable reviewer could have picked differently and the pick changes what Implement builds. Examples: where data lives, a new component or an extension of an existing one, a new dependency, an interface shape, a trade between simplicity and flexibility. For each one, record under Decisions in `design/index.md`:

- **At least two options**, each with at least one pro and one con.
- **The option chosen and the reason.**
- **That the user chose.** Present the options through `needs_input`, with your recommendation if you have one, and let the user decide. Never pick a significant option on your own.

**ADRs.** Link an existing ADR in `docs/registry/decisions/` wherever one applies, instead of re-deciding it. If a decision is new and is architecture-level, flag it "ADR" in the design. Close writes it into `docs/registry/decisions/` once the session has shipped, which keeps ADRs grouped and true to what was built. Don't write ADR files during Design. The design is your only artifact.

### Principles check

Every `DES-*` item and every significant choice gets a row in the principles check:

- **KISS and YAGNI: always**, for every element of every kind of solution.
- **SOLID** (single responsibility, open/closed, Liskov substitution, interface segregation, dependency inversion): **as well, for every software element** (code, modules, services, skills, agents, scripts, workflow definitions). For non-software elements such as documentation or a manual process, mark SOLID *n/a* with the reason.

Mark each principle with one of three values:

- *met*. Add a short reason where it isn't obvious, for example "one command, one endpoint".
- *traded off*, with the reason. The user resolves every *traded off* mark, either at a `needs_input` or at the gate, and the log records that decision.
- *n/a*, with the reason, for example "no substitutable types".

Bare *met* marks keep the table compact. Spell out only what isn't obvious.

**Rejected under YAGNI.** Any component, option or `DES-*` item that serves no live `REQ-*` is rejected. List it under "Rejected under YAGNI" in the principles check, with the reason, and design nothing for it. For example, a multi-channel notification framework is rejected when the only live requirement is email preferences.

## Design → Implement handoff

Implement builds from the Components (DES) table in `design/index.md`, so the table must be complete on its own. Its columns, in this order:

| Column | Holds |
|---|---|
| ID | `DES-001`, `DES-002`, … sequential and never reused, always the first column |
| Component | The component or layer, and the file or location it lives in |
| Covers | The live `REQ-*` it delivers |
| Result | What Implement must produce, concretely, for example "a `NotificationPreference` table related to `User`, created by a migration" |
| Check | How to tell the result is done, for example "the migration applies to a copy of the current database, and existing users keep their data" |
| Depends on | The `DES-*` items that must be built first, or `—` if none. For example, a save-preferences API depends on the storage it writes to, and the settings page depends on that API |

Refer to requirements by ID, and don't restate their text.

**Implementation order.** Under the table, give the order the Depends on column implies, for example "DES-001 → DES-002, DES-003 → DES-004". Implement orders its tasks from this order. Keep dependencies acyclic. If two items need each other, split one of them.

**Coverage self-check.** Before returning `done`, list every live `REQ-*` in the frozen `define/requirements.md` (deferred and struck rows need none) and confirm that each one appears in at least one Covers cell. Record the result under the table, for example "Coverage: all 12 live REQs covered". If a live requirement isn't covered, add or extend a `DES-*` item, or raise it with the user. Never leave it silently uncovered.

## Claude Design handoff

Design doesn't do visual UI design. That belongs to Claude Design. When the scope checklist marks **visual UI design** *in*, write `design/ui-handoff.md` from the template. It hands the visual work over and records what comes back.

**The handoff** names what needs visual design and the constraints on it:

- **Screens and components**: each screen and each component that needs visual design.
- **The `REQ-*` each one serves.**
- **States**: every state that needs a visual, for example loading, empty, saved, error, disabled.
- **Behaviour constraints** from the frontend design: the content each element shows, what each interaction does, validation, and anything the component hierarchy or routes fix.

**Never specify visual values.** No colour, font, typeface, size or spacing values go into the handoff or anywhere else in the design. The returned visual design decides them.

**Returned visual design.** Claude Design returns an HTML zip export. The handoff's "Returned visual design" slot holds three things:

1. **The zip, as-is**, at `assets/ui-design.zip`, linked. Never unzip it into the repo.
2. **One PNG screenshot per screen**, at `assets/ui-{screen}.png`, embedded so reviewers see it on GitHub, which can't render HTML inline. Take the screenshots from a temp copy of the export, by the route in [`reference/notations.md`](reference/notations.md#screenshots-of-the-claude-design-export).
3. **The Claude Design project link**, if there is one.

The design doesn't wait for the visual design. The slot can be filled later in the session, and it stays empty until then.

## On-demand files

Read these only when the step that needs them comes up.

| File | Read it when |
|---|---|
| [`kinds/three-tier.md`](kinds/three-tier.md) | The primary kind is three-tier application: the whole-system design, its approval step and the layer contract |
| [`reference/notations.md`](reference/notations.md) | Drawing any visual: the notation for the kind, the delta styling, captions, and rendering (including non-Mermaid sources and Claude Design screenshots) |
| [`reference/stack-defaults.md`](reference/stack-defaults.md) | A stack area is in scope: detect an established stack, or propose the default |
