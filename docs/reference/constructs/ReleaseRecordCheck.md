---
name: ReleaseRecordCheck
type: Utility
layer: Shared
file: skills/session/scripts/check-release.sh
status: built
planned_in: null
last_verified: null
---

# ReleaseRecordCheck

> Origin: #30

## Does

At the Deploy gate, reads `release.md`'s confirmed `Deploy tier:` line and checks that the record has every H2 section that tier requires by the Deploy standard's tier table, naming each missing one. It does NOT confirm the tier with the user (the orchestrator's gate step a1 does), judge completeness (gate step a2 does), or edit the record.

## Functional Requirements

- [ ] A full-tier record with no Rollback section prints "rollback missing" and exits 1, so the gate refuses the milestone and `log.md`'s `milestone` stays at `test`.
- [ ] A complete record at each tier (skip, short, full) prints "ok" and exits 0.
- [ ] Each section is checked against the tier table for each tier.
- [ ] A record with no `Deploy tier:` line prints "past record: no check" and exits 0.
- [ ] An unknown tier, or a missing `release.md`, exits 1.

## Proof

- method: null
- verified_by: null
- checklist_result: null
- test_file: tests/session/check_release_test.sh

## Interface

```text
check-release.sh <session-dir>
exit 0 ok, or past record · 1 a section missing (each named), bad tier, or no release.md
```

## Dependencies

- Calls: (none)
- Called by: `skills/session/SKILL.md` (Deploy gate step a2b)
- Reads: `{session}/release.md`
- Writes: (none)

## Patterns Applied

- [Never ship an incomplete product](../../registry/patterns.md#never-ship-an-incomplete-product)

## Key Decisions

- [ADR-008](../../registry/decisions/008-deploy-runs-declared-steps.md): risk-based tiers, confirmed by the user before the sections are checked.
