---
name: verification
description: Write and maintain a session's verification.md — VER-* rows that verify each REQ-*, in a fixed column order check-traceability.sh depends on. Used by the Test phase agent (REQ-011).
---

# Verification Skill

Use `${CLAUDE_PLUGIN_ROOT}/skills/session/templates/verification.md` for the file's structure — a single table, one row per check.

## Column order is load-bearing

```
| ID | Covers REQ | Method | Result | Evidence |
```

**Keep this exact order.** `${CLAUDE_PLUGIN_ROOT}/skills/session/scripts/check-traceability.sh` — the REQ-011 gate the orchestrator runs before the Test milestone can be approved — parses this table positionally (column 2 = the REQ(s) covered, column 4 = the result). Reordering or renaming columns silently breaks that check without erroring, so it would look like every requirement passed when the script simply stopped finding any of them. If a future revision needs a different shape here, `check-traceability.sh` has to change in the same commit.

## Rows

- **ID** — `VER-001`, `VER-002`, … sequential, never reused (same convention as `REQ-*`/`DES-*`).
- **Covers REQ** — the `REQ-*` id(s) this check verifies. One VER row can cover more than one REQ (comma-separated) if they're genuinely verified by the same check; don't force a single test to carry unrelated requirements just to save rows.
- **Method** — one of the four Test-owned methods (see **Test-owned verification** below): `integration`, `ui`, `playwright` or `inspection`. Prefer the strongest method that's actually practical; `inspection` is legitimate for a requirement about a document or instructions, but Evidence must say exactly what was read and what it showed. Past sessions' `unit`, `e2e` and `manual` rows stay as they are — don't rewrite them.
- **Result** — `pass`, `fail`, or `pending`. `check-traceability.sh` looks for the literal substring "pass" (case-insensitive) — don't write results like "passed previously, now failing," since that reads as a pass to the script. If a check regresses, update the row to `fail` and add a fresh row once it passes again rather than leaving ambiguous text in place.
- **Evidence** — a CI run link, a commit SHA, a test name or report path, or (for `inspection`) a one-line description of what was actually checked. Implement's unit and component tests may be cited here only as supporting evidence (see below).

## Test-owned verification

Testing is split between the phases (the Implement standard, `${CLAUDE_PLUGIN_ROOT}/skills/implement/SKILL.md`). Implement writes unit and component tests only. Test owns every method a `VER-*` row may use:

| Method | Use it for |
|---|---|
| `integration` | Parts running together for real, including a harness test that runs the real hooks and scripts (for example a repo's `tests/run.sh`) |
| `ui` | A user interface exercised as a user would, without a browser-automation framework |
| `playwright` | A browser-automated end-to-end test |
| `inspection` | A requirement about a document or instructions, checked by reading it |

- **At least one Test-owned row per requirement.** Every live `REQ-*` needs at least one `VER-*` row whose Method is one of the four above. A requirement verified only by Implement's unit or component tests isn't verified.
- **"Supporting:" evidence.** An Implement unit or component test appears only inside the Evidence cell of a Test-owned row, prefixed `Supporting:` (for example `tests/run.sh pass at abc123; Supporting: unit test parse_header_test`). It is never a row of its own, so a supporting citation can't satisfy the gate on its own.
- **Handed to Test.** Read `implement/as-built.md`'s Handed to Test section: each `DES-*` Check listed there needs a Test-owned test, so cover it with a row for the `REQ-*` that `DES-*` item covers. Its As-built section says what was actually built, including accepted variations. A past session has only a root `tasks.md`, so read that instead.

This rule is held by this standard and by the Test agent, not by the gate script: `check-traceability.sh` checks only that each `REQ-*` has a passing row, and is unchanged so past sessions pass exactly as before.

## The REQ-011 gate

**Every `REQ-*` in `define/requirements.md` (the root `requirements.md` in a past session that predates the `define/` folder) needs at least one `VER-*` row with a passing Result before the Test milestone can be approved.** A `REQ-*` you haven't verified yet should still get a row — `pending` or `fail`, naming why — rather than being left out of the table entirely; an absent REQ and an unverified REQ should both surface as "missing" to the gate, and a `pending`/`fail` row is more honest about what's actually been checked.

## Growing into a folder (later, #29)

Per D1a, once verification needs more than a Markdown table — e.g. a Playwright HTML/JSON report — `verification.md` can grow into a folder: the file stays as the entry point, and `verification/` beside it holds the native report, with each `VER-*` row linking to its result inside it. That's future work; the thin version here is a single Markdown table only.
