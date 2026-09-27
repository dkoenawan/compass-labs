---
name: requirements
description: Write and maintain a session's requirements — EARS-syntax REQ-* requirements with Given/When/Then acceptance criteria, checked against the ISO/IEC/IEEE 29148 quality rules, plus the per-type depth (priority, outcome trace, quality coverage, NFR measures) in types/{type}.md, the diagram catalogue and a worked example. Used by the phase agent that runs framing (D1c).
---

# Requirements Skill

This is the requirements standard for a session (D1c): one testable sentence per requirement, one acceptance criterion each. This file holds the rules every session type shares. It's one of the two artifact sections framing produces (the other is the problem statement, in the `problem-statement` skill); run the shared [framing](../framing/SKILL.md) step first, because its confirmed tier sets how deep the requirements go.

For a Feature session, requirements live in `define/requirements.md`, from `${CLAUDE_PLUGIN_ROOT}/skills/session/templates/define/requirements.md`. A past session that predates the `define/` folder keeps its root `requirements.md`; it's never migrated, and the same rules apply to it.

## Read your type's file

What the requirements must contain beyond the rules below depends on the session type and tier. Read the file your workflow's `framing.type_file` names, and only that one:

- [`types/feature.md`](types/feature.md): Feature sessions (priority, the Serves trace, the Deferred table, quality coverage, NFR measures, assumptions and dependencies, example-based criteria)
- [`types/bugfix.md`](types/bugfix.md): Bugfix sessions (corrected-behaviour rows with a regression criterion)

Also on demand: [`reference/methods.md`](reference/methods.md) (the verdict behind every method), [`reference/diagrams.md`](reference/diagrams.md) (the diagram catalogue and Mermaid rules), and the worked full-tier Feature example in [`examples/feature-full/`](examples/feature-full/index.md).

## EARS syntax

Each requirement is one sentence, in one of these patterns. Pick the pattern that actually fits — don't force everything into "When":

| Pattern | Form | Example |
|---|---|---|
| **Ubiquitous** | The `<system>` shall `<behavior>`. | The orchestrator shall record every handoff in `log.md`. |
| **Event-driven** | When `<trigger>`, the `<system>` shall `<behavior>`. | When a milestone is approved, the orchestrator shall commit and push before any `gh` call. |
| **State-driven** | While `<state>`, the `<system>` shall `<behavior>`. | While GitHub is unreachable, the orchestrator shall continue the session locally. |
| **Unwanted behavior** | If `<trigger>`, then the `<system>` shall `<behavior>`. | If a write targets a file outside the session's artifact set, then the guard hook shall block it. |
| **Optional feature** | Where `<feature is present>`, the `<system>` shall `<behavior>`. | Where a GitHub issue is linked, the orchestrator shall mirror milestone labels to it. |

## IDs

- `REQ-001`, `REQ-002`, … — sequential, **never reused**.
- **`ID` is always the table's first column.** `check-traceability.sh`, the Test gate, reads a requirement's ID only from the first column of a `| REQ-nnn |` row. Extra columns go after it; never reorder it.
- A dropped requirement is struck through (`~~REQ-004~~`) in the table, not deleted — the ID stays retired forever, and the row explains why it was dropped. A struck row doesn't match the gate's pattern, so it needs no `VER-*`.
- Downstream artifacts refer to a REQ by ID (`DES-*` names the `REQ-*` it covers, `tasks.md` names the `DES-*`, `VER-*` names the `REQ-*` it verifies) instead of repeating its text (D1).

## Acceptance criteria

Exactly one Given/When/Then per requirement, in the same table row (see the template):

> Given `<context>`, when `<action>`, then `<observable result>`.

It should be concrete enough that the Test phase can turn it directly into a `VER-*` check — vague criteria produce vague verification.

## Quality checklist (ISO/IEC/IEEE 29148)

Before a requirement goes in the table (and again before the Define milestone freezes the whole file), check each one against:

- **Necessary** — if it were removed, something the user actually needs would be missing.
- **Unambiguous** — one reading only; no "should probably," no undefined terms.
- **Verifiable** — the acceptance criterion can actually be checked (test, inspection, demonstration) — not "shall be fast" or "shall be intuitive."
- **Implementation-free** — states *what*, not *how*. ("The system shall persist the session's state" — not "…using a JSON file.") Implementation choices belong in `design.md`'s `DES-*` items, not here.
- **Consistent** — doesn't contradict another `REQ-*` in the same file.
- **Feasible** — achievable within the constraints already on record (see the Constraints section of `define/index.md`, or of the root `requirements.md` in a past session).

A requirement that fails one of these gets fixed before it's added, not flagged for later — this file is supposed to be trustworthy once frozen.

Each type file extends this checklist for its tiers (for Feature: priority present, Serves valid, and a concrete example at full tier).

## Defaults, not rigid rules

The type files say what content each requirement must have. Layouts, wording and templates they suggest are defaults, and named frameworks are offered, never mandated. The exceptions are mechanical, because a gate depends on them: `ID` as the first column of the `REQ-*` table, the struck-through form for dropped rows, and (for Feature) the Deferred table's column order.
