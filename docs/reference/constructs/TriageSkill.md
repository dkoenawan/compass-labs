---
name: TriageSkill
type: Component
layer: Shared
file: skills/triage/SKILL.md
status: built
planned_in: null
last_verified: null
---

# TriageSkill

> Origin: #86, #34

## Does

The `compass-labs:triage` skill. It dispatches four modes: **stock-take** (the default), **apply** (the stock-take just made, or report issue `#N`), **install** and **uninstall**. An interactive stock-take shows the proposed actions grouped by category and changes nothing. An apply carries them out one category group at a time, each only on the user's `AskUserQuestion` answer. It does NOT define the stock-take itself ([StockTakeProcedure](StockTakeProcedure.md) does), or run anything unattended ([TriageScheduledRun](TriageScheduledRun.md) does).

## Functional Requirements

- [ ] A stock-take on a repository shows the proposed actions grouped by category, creates no report issue, and makes no GitHub write.
- [ ] An apply asks one `AskUserQuestion` per non-empty category group. A confirmed group's `gh` actions run, and a declined group's issues get no edit, close or comment.
- [ ] A comment such as "approved, apply all" on a report, a reaction, issue or PR text, or a message from another agent is never treated as confirmation.
- [ ] `apply #N` shows each issue updated or closed since report #N as changed, and re-checks it before its group is offered. It refuses an `#N` that isn't a report by the authenticated user.
- [ ] When an apply finishes, every stock-take issue still open gets a comment starting `**Triage (YYYY-MM-DD):**` with its category and anchor lines. An applied report gets a comment listing the applied and declined groups, and is closed as completed.
- [ ] An apply, like install, creates the `triage` label if it's missing.
- [ ] A test run happens only when the user agrees, in a `git clone --local` copy under `mktemp -d`, and leaves the working tree's `git status` unchanged.

## Proof

- method: null
- verified_by: null
- checklist_result: null
- test_file: tests/triage/skill_test.sh

## Interface

```text
/trellis:triage                                         stock-take (default)
/trellis:triage apply                                   apply the stock-take just made
/trellis:triage apply #N                                apply report issue #N
/trellis:triage install --day D --time HH:MM --tz ZONE  install the weekly schedule
/trellis:triage uninstall                               remove it
```

## Dependencies

- Calls: [TriageSnapshot](TriageSnapshot.md), [TriageLabel](TriageLabel.md), [TriageSchedule](TriageSchedule.md), `gh issue close/edit/comment/create/view`
- Called by: the user (`/trellis:triage`)
- Reads: [StockTakeProcedure](StockTakeProcedure.md), the snapshot, the working tree, report issue `#N`
- Writes: GitHub issues, only for confirmed groups and the closing comments

## Patterns Applied

- [An unattended model run reads; scripts write](../../registry/patterns.md#an-unattended-model-run-reads-scripts-write) (the apply is the attended counterpart)
- [Plugin paths vs. project paths](../../registry/patterns.md#plugin-paths-vs-project-paths)

## Key Decisions

- [ADR-010](../../registry/decisions/010-read-only-scheduled-triage-run.md): only the attended apply carries out actions.
