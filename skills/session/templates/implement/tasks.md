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

<!-- The plan in the implement/ folder: the task checklist only. Tasks come from the design's Components (DES) table by the Implement standard's task rule (skills/implement/SKILL.md): each task names the DES-* it implements, tasks follow the Depends-on order, and an item's last task carries its Check, unless the Check needs a Test-owned test (then it goes under Handed to Test in as-built.md). Statuses, variations, layer artifacts and Handed to Test live in as-built.md, never here. -->

Each task names the `DES-*` item it implements. An item's last task carries its Check.

- [ ] {first task — no dependencies} [DES-{nnn}]
- [ ] {second task, last for its item} [DES-{nnn}] (depends on: 1) — check: {the item's Check}
- [ ] {third task} [DES-{nnn}] (depends on: 1)
- [x] {already completed task} [DES-{nnn}]
- [!] {failed and skipped task} [DES-{nnn}] (failed {date}: {reason} — manual fix needed)
