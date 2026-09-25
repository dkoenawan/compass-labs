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
- **Method** — `unit`, `e2e`, or `manual`. Prefer the strongest method that's actually practical; `manual` is legitimate but should say exactly what was checked and by whom in Evidence.
- **Result** — `pass`, `fail`, or `pending`. `check-traceability.sh` looks for the literal substring "pass" (case-insensitive) — don't write results like "passed previously, now failing," since that reads as a pass to the script. If a check regresses, update the row to `fail` and add a fresh row once it passes again rather than leaving ambiguous text in place.
- **Evidence** — a CI run link, a commit SHA, or (for `manual`) a one-line description of what was actually done to check it.

## The REQ-011 gate

**Every `REQ-*` in `requirements.md` needs at least one `VER-*` row with a passing Result before the Test milestone can be approved.** A `REQ-*` you haven't verified yet should still get a row — `pending` or `fail`, naming why — rather than being left out of the table entirely; an absent REQ and an unverified REQ should both surface as "missing" to the gate, and a `pending`/`fail` row is more honest about what's actually been checked.

## Growing into a folder (later, #29)

Per D1a, once verification needs more than a Markdown table — e.g. a Playwright HTML/JSON report — `verification.md` can grow into a folder: the file stays as the entry point, and `verification/` beside it holds the native report, with each `VER-*` row linking to its result inside it. That's future work; the thin version here is a single Markdown table only.
