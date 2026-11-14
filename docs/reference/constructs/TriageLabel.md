---
name: TriageLabel
type: Utility
layer: Shared
file: skills/triage/scripts/ensure-label.sh
status: built
planned_in: null
last_verified: null
---

# TriageLabel

> Origin: #86

## Does

Creates the `triage` label in a repository if it's missing. It's called only by the installer and the interactive apply, never by a scheduled run, which publishes unlabelled instead.

## Functional Requirements

- [ ] With no `triage` label, it makes exactly one `gh label create triage` call and exits 0.
- [ ] With the label present, it makes no create call and exits 0.
- [ ] A failed list or create exits non-zero with the reason.
- [ ] Neither `run-scheduled.sh` nor `publish-report.sh` calls it or creates a label.

## Proof

- method: null
- verified_by: null
- checklist_result: null
- test_file: tests/triage/ensure_label_test.sh

## Interface

```text
ensure-label.sh <repo>
exit 0 label exists or created · non-zero with the reason
```

## Dependencies

- Calls: `gh label list`, `gh label create triage --description "Triage report"`
- Called by: [TriageSchedule](TriageSchedule.md) (install), [TriageSkill](TriageSkill.md) (apply)
- Reads: the repository's labels
- Writes: the `triage` label

## Patterns Applied

- [An unattended model run reads; scripts write](../../registry/patterns.md#an-unattended-model-run-reads-scripts-write)

## Key Decisions

- [ADR-010](../../registry/decisions/010-read-only-scheduled-triage-run.md): label creation stays out of the unattended run.
