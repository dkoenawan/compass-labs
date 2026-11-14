---
name: TriageReportPublisher
type: Utility
layer: Shared
file: skills/triage/scripts/publish-report.sh
status: built
planned_in: null
last_verified: null
---

# TriageReportPublisher

> Origin: #86

## Does

Validates a stock-take report against its snapshot and publishes it as one `Triage YYYY-MM-DD` report issue, then closes the authenticated user's earlier unapplied reports as superseded. It is the only code that writes on GitHub in a scheduled run. It does NOT create labels, or touch any issue other than its own reports.

## Functional Requirements

- [ ] A valid report gives exactly one `gh issue create` and one `gh issue close --reason "not planned"` of each earlier open report, with a comment linking the new one.
- [ ] A report that misses an issue, adds one, repeats an entry, has text before `## Header`, has an unknown heading, lacks `## Proposed actions`, or exceeds 65,536 characters makes no `gh` call at all and exits 1.
- [ ] If `Triage {date}` by the authenticated user already exists in any state, it prints "already published" and creates nothing. One by another author doesn't block.
- [ ] Without the `triage` label it publishes with no `--label`, makes no `label` call, and adds a note saying the label is missing.
- [ ] It never calls `issue edit`, `issue comment` or `label create`. A failed create closes nothing, and a failed superseded close exits 3.
- [ ] The published body's `## Header` `- Run date:` line is `<date>`, the title's date: a different date is replaced and a missing line is added, and nothing outside the header changes.

## Proof

- method: null
- verified_by: null
- checklist_result: null
- test_file: tests/triage/publish_report_test.sh

## Interface

```text
publish-report.sh <repo> <snapshot-dir> <report.md> <date>
exit 0 published or already published · 1 invalid, or gh failure before create · 3 published, superseded close failed
```

## Dependencies

- Calls: `gh issue list/create/close`, `jq`
- Called by: [TriageScheduledRun](TriageScheduledRun.md)
- Reads: the snapshot's `issues.json`, `reports.json` and `meta.json`; the report file
- Writes: one report issue; closes superseded report issues

## Patterns Applied

- [An unattended model run reads; scripts write](../../registry/patterns.md#an-unattended-model-run-reads-scripts-write)

## Key Decisions

- [ADR-010](../../registry/decisions/010-read-only-scheduled-triage-run.md): validate before any write, so a run never leaves a partial report.
