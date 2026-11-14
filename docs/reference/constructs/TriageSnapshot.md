---
name: TriageSnapshot
type: Utility
layer: Shared
file: skills/triage/scripts/gather.sh
status: built
planned_in: null
last_verified: null
---

# TriageSnapshot

> Origin: #86

## Does

Takes a read-only snapshot of a repository's open issues for a stock-take, into a given folder: open issues without report issues, open report issues by the authenticated user, recent merged PRs with their changed files, the README's anchor and run metadata. With `--report N` it also lists the issues in report N that were updated or closed since N was created. It does NOT write on GitHub or in the repository.

## Functional Requirements

- [ ] Its only `gh` calls are `issue list/view`, `pr list`, `label list` and `api user`, and the repository's working tree is unchanged after it runs.
- [ ] A `Triage YYYY-MM-DD` issue by the authenticated user is left out of `issues.json` and listed in `reports.json`. A look-alike title by another author stays in `issues.json`.
- [ ] `meta.json` says `anchor: missing` for a README without `<!-- compass:anchor -->` markers, and `label_exists` is false when the `triage` label is absent.
- [ ] `--report N` writes `changed.json` naming each issue updated or closed after N's creation, with its reasons. It refuses an `N` that isn't a report by the authenticated user.
- [ ] A `gh` failure exits non-zero, naming it.

## Proof

- method: null
- verified_by: null
- checklist_result: null
- test_file: tests/triage/gather_test.sh

## Interface

```text
gather.sh <repo> <out-dir> [--report N] [--prs N]      (--prs default 200)
writes issues.json reports.json merged-prs.json [anchor.md] meta.json [changed.json]
exit 0 ok · non-zero on a gh failure or a non-report N
```

## Dependencies

- Calls: `gh`, `git rev-parse`, `jq`
- Called by: [TriageScheduledRun](TriageScheduledRun.md), [TriageSkill](TriageSkill.md)
- Reads: GitHub issues, PRs and labels; the repository's `README.md`
- Writes: the snapshot folder only

## Patterns Applied

- [An unattended model run reads; scripts write](../../registry/patterns.md#an-unattended-model-run-reads-scripts-write)

## Key Decisions

- [ADR-010](../../registry/decisions/010-read-only-scheduled-triage-run.md)
