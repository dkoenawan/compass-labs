---
issue: {github-issue-number}
branch: {branch-name}
status: in-progress
test_command: {test-command or null}
last_skill_commit: null
retry_counts:
schedule: null
budget:
  max_tasks_per_run: 3
  max_wall_clock_minutes: 90
  stop_on_first_failure: true
---

Each task names the `DES-*` item it implements.

- [ ] {first task — no dependencies} [DES-{nnn}]
- [ ] {second task} [DES-{nnn}] (depends on: 1)
- [ ] {third task} [DES-{nnn}] (depends on: 1)
- [x] {already completed task} [DES-{nnn}]
- [!] {failed and skipped task} [DES-{nnn}] (failed {date}: {reason} — manual fix needed)

## Deviations from design

_None yet._
