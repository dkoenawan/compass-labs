<!-- The as-built record in the implement/ folder (skills/implement/SKILL.md). Four sections, tables only: never a checklist line here, so nothing in this file can be read as a task. Frozen define/ and design/ are never edited; a difference from the design is recorded as a variation below and decided at the Implement gate. -->
# As built: Triage skill

> Phase: Implement | Started: 2026-11-14 | Status: in progress
> Design: [`design/index.md`](../design/index.md) · Plan: [`tasks.md`](tasks.md) · Session history: [`log.md`](../log.md)

## As-built

<!-- One row per DES-* item in the design, each with exactly one status: built as designed | built with variation | not built. A reason is required for any status other than built as designed. A layer with no Implement guidance records "no Implement guidance for {layer}" and its follow-up issue in the Reason. Name the unit and component tests (files or test names), or "none" with the reason. -->

| DES | Status | Reason | Unit tests | Component tests |
|---|---|---|---|---|

## Variations

<!-- One row per difference between the design and what was built. IDs V1, V2 … are local to this file. Every variation is decided at the Implement gate: accepted as built, or sent back for rework. Write "None." under the heading when there are none. -->

| ID | DES | Designed | Built | Why |
|---|---|---|---|---|
| V1 | DES-008 | DES-008 depends on DES-003 to DES-007, so its tasks come after theirs, and it holds the tests for those items | DES-008's stubs and helpers (task 1) are built first. Each of DES-003 to DES-007 commits its own `tests/triage/*_test.sh` with its script (tasks 3 to 7). DES-008's last task (10) still follows every item it depends on, adds the isolation test and runs the full harness | Each script's Check is a stub test, so the stubs must exist before the first script. The Implement standard commits a task's code with its tests, and a test written later would leave each script's task without its Check |
| V2 | DES-008, DES-009 | Implementation order DES-001 → DES-008 → DES-009 | DES-009 (task 9) is built before DES-008's last task (10). Depends on still holds: DES-009 needs DES-001 and DES-006, and DES-008 doesn't need DES-009. From task 2's commit to task 9's commit, `tests/session/marketplace_test.sh` fails, because `skills/triage/` exists without a `SKILL.md` and then without a marketplace entry | `marketplace_test.sh` requires every `skills/*/` folder to have a `SKILL.md` that `marketplace.json` lists, so DES-008's Check (`bash tests/run.sh` passes) can only pass after DES-009. Listing the skill earlier would make a task span two items |

## Layer artifacts

<!-- One subsection per layer this session built, shaped by that layer's guidance (skills/{layer}/reference/implement.md). Delete the example subsection when no layer has an artifact. -->

## Handed to Test

<!-- One row per DES-* Check that needs a Test-owned test (integration, ui, playwright or inspection). Implement never writes those tests. -->

| DES | Check |
|---|---|
