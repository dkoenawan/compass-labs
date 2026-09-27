<!-- tier: skip, short, full. The ID first column and the Deferred table's column order are fixed: check-traceability.sh depends on them. -->
# Requirements: {Session Title}

> Part of [index](index.md) · Define

## Requirements

EARS syntax. Each requirement has one acceptance criterion in Given/When/Then form. IDs are never reused; a dropped requirement is struck through, not deleted. A Won't meaning "never" is struck through with its reason; a Won't meaning "later" moves to the Deferred table below.

- **"{Term}"** means {definition}. <!-- glossary; delete if there are no terms to define -->

<!-- Priority: Must | Should | Could (short, full; "—" at skip). Serves: OUT-nn or NEED-nn IDs from problem.md (short, full; "—" at skip). -->
| ID | Requirement | Priority | Serves | Acceptance criterion |
|---|---|---|---|---|
| REQ-001 | {When/While/If [trigger], the [system] shall [behavior].} | {Must} | {OUT-01} | Given {context}, when {action}, then {result}. |

## Deferred

<!-- One row per requirement moved to later work. The follow-up issue comes first and is required. If none, replace the table with "None". -->
| Follow-up | Was | Requirement | Reason |
|---|---|---|---|
| #{nnn} | REQ-{nnn} | {the requirement as it stood} | {why it moved to later work} |
