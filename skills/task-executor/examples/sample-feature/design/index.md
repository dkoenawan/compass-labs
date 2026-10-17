# Design: User Roles

> Sample design (example input for task-executor), trimmed to the parts task-executor reads: the Components (DES) table and the Implementation order. A real `design/index.md` follows `skills/session/templates/design/index.md`.

## Components (DES)

| ID | Component | Covers | Result | Check | Depends on |
|---|---|---|---|---|---|
| DES-001 | Database: `User.role` in the schema | REQ-001 | A `role` field on `User` with values `admin`, `member` and `viewer`, created by a migration | The migration applies to a copy of the current database, and existing users get `member` | — |
| DES-002 | Backend: `AssignRoleCommand` and `POST /admin/users/{id}/role` | REQ-002 | Only an admin may assign a role; other callers get 403 | An admin assigning a role gets 200, and a member gets 403 | DES-001 |
| DES-003 | Frontend: role badge and selector at `/admin/users` | REQ-003 | Each user in the list shows a role badge, and an admin can change it | Choosing a role in the selector updates the badge | DES-002 |

**Implementation order** (from Depends on): DES-001 → DES-002 → DES-003
