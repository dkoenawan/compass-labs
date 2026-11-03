<!-- The as-built record in the implement/ folder (skills/implement/SKILL.md). Four sections, tables only: never a checklist line here, so nothing in this file can be read as a task. Frozen define/ and design/ are never edited; a difference from the design is recorded as a variation below and decided at the Implement gate. -->
# As built: Deploy phase depth

> Phase: Implement | Started: 2026-11-03 | Status: in progress (wave 1 of 4 built: DES-001, DES-005, DES-008, DES-010)
> Design: [`design/index.md`](../design/index.md) · Plan: [`tasks.md`](tasks.md) · Session history: [`log.md`](../log.md)

## As-built

<!-- One row per DES-* item in the design, each with exactly one status: built as designed | built with variation | not built. A reason is required for any status other than built as designed. A layer with no Implement guidance records "no Implement guidance for {layer}" and its follow-up issue in the Reason. Name the unit and component tests (files or test names), or "none" with the reason. -->

| DES | Status | Reason | Unit tests | Component tests |
|---|---|---|---|---|
| DES-001 | built as designed | `skills/deploy/SKILL.md`, `reference/declaration.md`, `reference/frameworks.md`; listed in `marketplace.json` and `README.md`. The "Declaration offer" procedure and `starter` mode are DES-014's, added in task 18 | none: a standard is a document, so its content is checked by a content test, not a unit test | `tests/session/deploy_standard_test.sh` (item fields, tier risks and section rows, framework verdicts, examples parse as JSON); `tests/session/marketplace_test.sh` passes with `./skills/deploy` listed |
| DES-002 | not built | In progress: wave 2 (tasks 8, 9) | | |
| DES-003 | not built | In progress: wave 2 (task 10) | | |
| DES-004 | not built | In progress: wave 3 (task 12) | | |
| DES-005 | built as designed | Clause added as `## Deploy clause` at the end of the contract. The Output section's `needs_input` line also points to it, so the contract doesn't say only Define and Design may ask | none: a contract document | `tests/session/deploy_contract_test.sh` (clause present, rules 1 and 2 unchanged); `tests/hooks/*_test.sh` pass unchanged |
| DES-006 | not built | In progress: wave 3 (task 13) | | |
| DES-007 | not built | In progress: wave 4 (task 16) | | |
| DES-008 | built with variation | V2 | none: the script is one unit tested through its interface | `tests/session/release_tag_test.sh` (compass-labs' values against a bare origin and a stub `gh`: changed, unchanged, tag exists and doesn't move, `--check` creates nothing; a plain-text `VERSION` file; template is generic) |
| DES-009 | not built | In progress: wave 2 (task 11) | | |
| DES-010 | built as designed | Only the `"version"` line of `plugin.json` changes; the rest of the file keeps its formatting | none: one small script, tested through its interface | `tests/session/bump_version_test.sh` (2.2.1 minor gives 2.3.0; patch, major; a bad or missing level exits 1 and changes nothing; no commit) |
| DES-011 | not built | In progress: wave 3 (task 14) | | |
| DES-012 | not built | In progress: wave 4 (task 17) | | |
| DES-013 | not built | In progress: waves 2 and 4 (tasks 7, 21). See V1 | | |
| DES-014 | not built | In progress: wave 4 (tasks 18, 19) | | |
| DES-015 | not built | In progress: wave 3 (task 15) | | |
| DES-016 | not built | In progress: wave 4 (task 20) | | |

## Variations

<!-- One row per difference between the design and what was built. IDs V1, V2 … are local to this file. Every variation is decided at the Implement gate: accepted as built, or sent back for rework. Write "None." under the heading when there are none. -->

| ID | DES | Designed | Built | Why |
|---|---|---|---|---|
| V1 | DES-013 | DES-013 depends on DES-002, DES-006, DES-008, DES-010 and DES-015, so its tasks come after theirs | DES-013's fixture repos (task 7) are built before DES-002's tasks (8, 9). Its last task (21) still follows every item it depends on | DES-002's Check, and DES-015's, run their component tests on the four fixtures, so the fixtures must exist first. Building them inside DES-002's task would make one task span two items |
| V2 | DES-008 | `release-tag.sh` compares versions, tags and publishes, or fails on an existing tag; `--check` prints the tag and warns if it exists | As designed, plus two small additions: the script refuses to run while its settings block still holds the template's placeholders, and `--check` adds a note when the version is unchanged from `HEAD^1` (so a merge would create no tag) | The refusal stops an unfilled template copy from tagging with a wrong file or tag form. The note makes the pull-request check honest for a PR that doesn't bump the version (REQ-021) |

## Layer artifacts

<!-- One subsection per layer this session built, shaped by that layer's guidance (skills/{layer}/reference/implement.md). Delete the example subsection when no layer has an artifact. -->

None. The design's primary kind is plugin/tooling, and no `DES-*` Component cell names a layer, so no `skills/{layer}/reference/implement.md` applies.

## Handed to Test

<!-- One row per DES-* Check that needs a Test-owned test (integration, ui, playwright or inspection). Implement never writes those tests. -->

| DES | Check |
|---|---|
| DES-001 | Inspection: a reviewer writes `fixture-service`'s declaration from the standard alone |
