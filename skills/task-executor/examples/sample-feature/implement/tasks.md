---
issue: 42
branch: feat/user-roles
status: in-progress
test_command: bun test
last_skill_commit: a3f8c1d2e9b047f6a1234567890abcdef12345678
retry_counts:
  4: 1
schedule: "0 */6 * * *"
budget:
  max_tasks_per_run: 3
  max_wall_clock_minutes: 90
  stop_on_first_failure: true
---

Each task names the `DES-*` item it implements. An item's last task carries its Check.

- [x] Add `User.role` field to the schema [DES-001]
- [x] Generate and apply the migration [DES-001] (depends on: 1) — check: the migration applies to a copy of the current database, and existing users get `member`
- [x] Implement `AssignRoleCommand` with validation, with its unit test [DES-002] (depends on: 2)
- [!] Wire up `POST /admin/users/{id}/role`, with its component test [DES-002] (depends on: 3) (failed 2026-05-01: tsc errors in adjacent file — `src/routes/admin.ts` has unrelated type errors blocking compilation)
- [ ] Add role badge and selector to the user list, with their component tests [DES-003] (depends on: 4) — check: choosing a role in the selector updates the badge
