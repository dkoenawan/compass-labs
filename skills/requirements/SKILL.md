---
name: requirements
description: Write and maintain a session's requirements.md — EARS-syntax REQ-* requirements with Given/When/Then acceptance criteria, checked against the ISO/IEC/IEEE 29148 quality rules. Used by the Define phase agent (D1c).
---

# Requirements Skill

This is the **default** requirements standard for a session (D1c). It's deliberately lightweight — one testable sentence per requirement, one acceptance criterion each. Deeper research into requirements methodology is tracked separately (#32); don't block on it.

Use `${CLAUDE_PLUGIN_ROOT}/skills/session/templates/requirements.md` for the file's section structure. This skill covers how to fill in the **Requirements** section well.

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
- A dropped requirement is struck through (`~~REQ-004~~`) in the table, not deleted — the ID stays retired forever, and the row explains why it was dropped.
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
- **Feasible** — achievable within the constraints already on record (see the Constraints section of `requirements.md`).

A requirement that fails one of these gets fixed before it's added, not flagged for later — this file is supposed to be trustworthy once frozen.
