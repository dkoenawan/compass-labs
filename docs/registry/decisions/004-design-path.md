---
id: "004"
date: 2026-10-10
status: Accepted
deciders: [Daniel Koenawan]
affects: [design, session, plan, init, bootstrap-new-project, explore, task-executor]
issue: https://github.com/dkoenawan/compass-labs/issues/27
---

# ADR-004: One Design path, layered by solution kind, with a `design/` folder and visual deltas

> Origin: #27

## Context

The Feature session's Design phase wrote `design.md` from a five-section template, with no visuals, no delta against the current system and no per-layer structure. A reviewer had to reconstruct from prose what a design added, changed or retired, and layer decisions could be made silently. A second path, the `plan` skill, also produced designs: it hard-coded DB → Backend → Frontend with Prisma and CQRS, and wrote its own spec file outside any session. Per-layer Implement skills (#28) were about to arrive with no matching per-layer design to follow.

Constraints: the phase-agent contract stays as it is (one artifact per phase, user questions only through the orchestrator, no `log.md` writes); past sessions keep working unchanged; every visual has to render on github.com; and the plugin is publicly distributed, so stack choices are defaults, never mandates.

## Decision

We will make **Design the plugin's only design path**: one standard skill (`design`), preloaded by the Design agent, with an **in-depth path per solution kind** (three-tier application today) and **one home per layer** shared with that layer's Implement skill. **Design's output becomes a `design/` folder**, gated by `check-design.sh`, with a context view and a delta list. **`plan` is retired.**

| # | Decision |
|---|---|
| D1 | One primary kind per solution, plus a scope checklist for the other areas it touches. A kind without an in-depth path uses the all-kinds sections and names its follow-up issue. |
| D2 | Design records each significant choice's options and the user's choice, links existing ADRs, and flags new architecture-level decisions "ADR". **Close writes those ADRs** into `docs/registry/decisions/`, numbered then. Design never writes ADR files. |
| D3 | One notation catalogue, `skills/design/reference/notations.md`, which kind files point to. |
| D4 | The delta is drawn as C4 abstractions in a Mermaid `flowchart`, with four classDefs (`new`, `changed`, `deprecated`, `unchanged`) and a `[status]` label suffix. The delta list table is the source of truth. Mermaid's native `C4Context` is not used. |
| D5 | Design's artifact is a `design/` folder with a fixed file set (`index.md`, `solution.md`, `frontend.md`, `backend.md`, `database.md`, `ui-handoff.md`), with `design.md` as its legacy artifact. The layout alone tells old sessions from new, so `check-design.sh` skips past sessions. |
| D6 | The Design agent has Bash, limited by its own rule to render and render-check commands writing to `assets/` or a temp directory. The gate's `git status` precondition catches stray writes. No Bash-parsing hook. |
| D7 | Each layer's home is `skills/{layer}/`, holding `reference/design.md` and `reference/implement.md`. Nothing is created until a layer issue delivers it. No stubs. |
| D8 | The Design path writes no construct stubs. Close adds the constructs a session built. Design ignores `planned_in` pointers into `docs/sessions/`. |
| D9 | `skills/plan/` is deleted and its callers repointed to `/compass-labs:session`. Its capabilities are carried into Design or the layer issues, or dropped with a reason. |
| D10 | Stack defaults have a single source, `skills/design/reference/stack-defaults.md`. An established stack always wins over a default. |
| D11 | Visual UI design is delegated to Claude Design. Its HTML zip export is kept as-is in `assets/`, with one PNG per screen embedded for GitHub. |
| D12 | Design reads prior knowledge only from the project docs, the code and the current session, never from a past session folder. |

**This refines [ADR-002](002-session-lifecycle.md) and extends [ADR-003](003-framing-and-project-anchor.md).** As with Define's `define/` folder (ADR-003), the Design phase still owns exactly one artifact, now a folder with a fixed file set, one level deep. ADR-003's "Renderable" NFR now covers Design too: every visual is Mermaid, or a committed SVG beside a non-Mermaid source.

## Options Considered

| Option | Pros | Cons | Why rejected |
|--------|------|------|--------------|
| **One standard skill with on-demand kind, notation and stack files, a `design/` folder and a gate script (chosen)** | Reuses patterns the repo already has and tests (ADR-003's standards skills, folder artifact, gate script); kinds and layers plug in by adding files | Design preloads a larger skill; the guard and workflow gain a second folder artifact | — chosen |
| Notation and depth declared in a `design` block in `workflows/feature.json` | Machine-readable | Workflow files are per session type, notation is per solution kind; JSON can't hold examples | Wrong axis (D3) |
| Flat `design.md` with layer sections | No workflow or guard change | Needs a marker to tell new sessions from old; three layers overcrowd one file | Rejected for D5 |
| Mermaid `C4Context` / `C4Container` with per-element styles | Literal C4 diagram types | Experimental in Mermaid, no tags or legend, weak layout, GitHub rendering unverified | Rejected for D4 |
| Design writes a *Proposed* ADR during the phase | Linked from day one | Breaks one-artifact ownership; records decisions that may still change; numbers clash across parallel sessions | Rejected for D2 |
| No Bash for the Design agent; the user renders by hand | Narrower toolset | A manual step before every gate with a non-Mermaid visual; nothing checks rendering | User chose Bash (D6) |
| Layer standards under `skills/design/layers/` | Design material together | Two homes per layer (design here, Implement elsewhere) | Rejected for D7 |
| Keep `plan` as a redirect | Friendlier to muscle memory | A skill that only redirects; stub-like bodies fail the Deploy completeness check | Rejected for D9 |
| Stack defaults in a README section | Visible to users | Agents would read a standard from user documentation | Rejected for D10 |

## NFR Captured

- Renderable: 0 visuals in a design that show as source text on github.com, counted at the Design gate. Non-Mermaid visuals ship as a committed SVG beside their source.
- Compatible: a past session with a root `design.md` gets exactly the guard, gate and traceability results it got before the `design/` folder existed.
- Bounded: `design/` holds at most six named files, one level deep; the guard blocks anything else.
- Portable: Design runs in a repo with no docs (designing from the Define output and code), and in any established stack.

## Consequences

**Now easier**: Seeing what a design changes at a glance; adding an in-depth path for a kind or a layer standard without touching the procedure; Implement ordering tasks from `DES-*` results, checks and dependencies; keeping one statement of stack defaults.
**Now harder**: A three-tier Design takes an extra approval step; the Design agent's Bash isn't hook-enforced; `/compass:plan` users have to move to `/compass-labs:session` (a MAJOR version bump, v2.0.0).
**New constraints**: Only Close writes ADRs that come out of a design. The Components table's first column stays `ID`, and its column order is fixed. A session never holds both `design/` and a root `design.md`. Visuals use only notations from the catalogue. No file outside `stack-defaults.md` restates a different default stack.

## Revisit Conditions

If a stray write from the Design agent's Bash ever reaches a commit, add a Bash-matching guard hook. If a kind or layer can't plug in without changing the procedure or the all-kinds sections, revisit D1 and the layer contract. If GitHub's Mermaid support for C4 matures (tags and a legend), revisit D4.
