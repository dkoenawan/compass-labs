<!-- The as-built record in the implement/ folder (skills/implement/SKILL.md). Four sections, tables only: never a checklist line here, so nothing in this file can be read as a task. Frozen define/ and design/ are never edited; a difference from the design is recorded as a variation below and decided at the Implement gate. -->
# As built: Triage scheduled-run fixes

> Phase: Implement | Started: 2026-11-14 | Status: in progress
> Design: [`design/index.md`](../design/index.md) · Plan: [`tasks.md`](tasks.md) · Session history: [`log.md`](../log.md)

## As-built

<!-- One row per DES-* item in the design, each with exactly one status: built as designed | built with variation | not built. A reason is required for any status other than built as designed. A layer with no Implement guidance records "no Implement guidance for {layer}" and its follow-up issue in the Reason. Name the unit and component tests (files or test names), or "none" with the reason. -->

| DES | Status | Reason | Unit tests | Component tests |
|---|---|---|---|---|
| DES-001 | built as designed | No Implement guidance for plugin/tooling (#89; the Design path is #51): built with the repository's conventions (Bash, `tests/run.sh`). `resolve_bin` ends with `[[ "$found" = /* ]] \|\| found="$PWD/$found"` and `echo "$found"`, for the PATH lookup and the override alike; the executable check, the `%`/`'`/newline refusal and the cron line shape are unchanged. The header comment says the paths are absolute and not symlink-resolved. The new cases fail against the old `realpath` code | none: one script tested through its interface | `tests/triage/schedule_test.sh`: (a) `claude` and `gh` on PATH as symlinks to `versions/1.0.0` stubs, overrides unset, give `TRIAGE_CLAUDE_BIN='{dir}/claude'`, `TRIAGE_GH_BIN='{dir}/gh'` and no `versions/1.0.0`; (b) `TRIAGE_CLAUDE_BIN=bin/claude` from a directory holding that symlink gives `'{cwd}/bin/claude'` on both lines; the existing cases still pass |

## Variations

<!-- One row per difference between the design and what was built. IDs V1, V2 … are local to this file. Every variation is decided at the Implement gate: accepted as built, or sent back for rework. Write "None." under the heading when there are none. -->

None.

## Layer artifacts

<!-- One subsection per layer this session built, shaped by that layer's guidance (skills/{layer}/reference/implement.md). Delete the example subsection when no layer has an artifact. -->

No layer artifact: the only layer is plugin/tooling, which has no Implement guidance yet (#89).

## Handed to Test

<!-- One row per DES-* Check that needs a Test-owned test (integration, ui, playwright or inspection). Implement never writes those tests. -->

| DES | Check |
|---|---|
