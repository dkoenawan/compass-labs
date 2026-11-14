<!-- tier: full -->
# Quality: Triage skill

> Part of [index](index.md) · Define

## Quality coverage (ISO/IEC 25010:2023)

| Characteristic | Covered by | Not applicable because |
|---|---|---|
| Functional suitability | REQ-001 to REQ-009, REQ-028 | |
| Performance efficiency | REQ-024 | |
| Compatibility | REQ-020, REQ-021 (the schedule coexists with other cron jobs and leaves them unchanged) | |
| Interaction capability | REQ-013, REQ-014, REQ-017 (the user sees grouped actions and confirms group by group) | |
| Reliability | REQ-011, REQ-022, REQ-023 (no partial or duplicate reports; a superseded report doesn't linger) | |
| Security | REQ-010, REQ-012, REQ-015, REQ-025 (an unattended run can't change issues, run repository code, be approved from outside an apply, or be steered by issue text) | |
| Maintainability | | The skill is built and tested to the plugin's existing conventions (CLAUDE.md skill structure, `tests/run.sh`). No user-facing behaviour of this feature depends on it, so it gets no requirement of its own. |
| Flexibility | REQ-005, REQ-019 (any repository, with or without an anchor; any day, time and time zone) | |
| Safety | | The skill causes no physical harm and controls no equipment. The risk of wrongly losing issues is handled under Security and by the confirmation in REQ-014. |

## NFR measures

| Requirement | Scale | Tolerable | Goal |
|---|---|---|---|
| REQ-024 | Minutes from a scheduled run's start to its report issue existing on GitHub, for a repository with 100 open issues | 60 | 30 |

## Assumptions and dependencies

**Assumptions:**
- The machine running the schedule is switched on and online at the scheduled time. A run missed because it was off isn't caught up.
- `gh` on that machine is authenticated with permission to create, comment on and close issues and to create labels.
- A report for up to 100 issues fits in one GitHub issue body (limit 65,536 characters).
- The `claude` CLI can run headless under cron, as `doc-maintainer` and `task-executor` already do.

**Dependencies:**
- GitHub and the `gh` CLI: relied on by REQ-001, REQ-002, REQ-008, REQ-010, REQ-011, REQ-014, REQ-016, REQ-022, REQ-023, REQ-028.
- The machine's cron and its time-zone database: relied on by REQ-019, REQ-020, REQ-021.
- The project anchor contract (`skills/framing/reference/anchor-contract.md`): relied on by REQ-004, REQ-005.
- The `triage` label existing in the repository: relied on by REQ-001, REQ-023, REQ-028 (who creates it is an open question in [index](index.md#open-questions)).
