# Bugfix requirements

> Standard: [requirements](../SKILL.md) · Methods: [reference/methods.md](../reference/methods.md)

A Bugfix session's requirements state the **corrected behaviour**: what the system shall do in the situation that failed. This file stays at the depth the Bugfix workflow needs today. Deeper Bugfix content is tracked in #40, and the Bugfix workflow itself in #24.

## Required content

- **Corrected-behaviour rows.** One `REQ-*` row per behaviour the fix restores or changes, in the shared table rules (`ID` first, EARS, never reused). The "If ⟨trigger⟩, then the ⟨system⟩ shall ⟨behaviour⟩" pattern usually fits, because a bug is an unwanted-behaviour case.
- **A regression criterion.** Each row's one Given/When/Then reproduces the original failure: the Given and When are the reproduction steps from the problem statement, and the Then is the corrected result. So the criterion doubles as the regression check the Test phase runs.
- **The quality checklist**, as in the shared rules. "Necessary" means the row traces to the observed symptom.

## Methods applied

Each has a Bugfix **adopt** verdict in [reference/methods.md](../reference/methods.md): **EARS**, the **ISO/IEC/IEEE 29148** checks and **Given/When/Then**.

## Example

| ID | Requirement | Acceptance criterion |
|---|---|---|
| REQ-001 | If a reset link is opened after it has already been used, then the wiki shall refuse it and offer to send a new one. | Given a reset link that was used at 10:02, when it's opened again at 10:05, then the page says the link has been used and offers a new link, and the password is unchanged. |
