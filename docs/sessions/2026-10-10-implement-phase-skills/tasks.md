---
issue: 28
branch: feat/28-implement-phase-skills
status: in-progress
test_command: bash tests/run.sh
last_skill_commit: null
retry_counts:
schedule: null
budget:
  max_tasks_per_run: 12
  max_wall_clock_minutes: 240
  stop_on_first_failure: true
---

Each task names the `DES-*` item it implements. This session uses the legacy root layout (design/index.md Risks): it runs on the old Implement agent and template, so it has a root `tasks.md` with a "Deviations from design" section, not an `implement/` folder.

- [x] Plan lookups read both layouts: `find-active-plan.sh` searches `docs/sessions/*/implement/tasks.md` and `docs/sessions/*/tasks.md`; `doc-maintainer`'s fold-back eligibility reads `implement/tasks.md` or a root `tasks.md`; a fixture repo with one in-progress plan in each layout is found [DES-011]
- [x] Implement templates `skills/session/templates/implement/tasks.md` and `implement/as-built.md` (four table-only sections, no "Deviations from design"); root `templates/tasks.md` unchanged [DES-002] (depends on: 1) — check: `select-next-task.sh` on a filled-in `implement/tasks.md` returns only checklist tasks; `as-built.md` has the four headings and no `- [ ]` lines; neither has "Deviations from design"
- [x] `feature.json` Implement phase: `artifact: "implement/"`, `artifact_files`, `legacy_artifact: "tasks.md"`, `implement/` in the allowlist; guard cases for `implement/` in `session_guard_test.sh`; `workflow_test.sh` asserts the entry [DES-011] (depends on: 2) — check: guard cases pass, `workflow_test.sh` passes, `check_traceability_test.sh` and `check_design_test.sh` pass unchanged
- [x] Test boundary: Test-owned methods (`integration`, `ui`, `playwright`, `inspection`), at least one Test-owned row per live REQ, "Supporting:" evidence, Handed to Test read, in `agents/test.md`, `skills/verification/SKILL.md` and `templates/verification.md` [DES-009] (depends on: 3) — check: `requirements_verification_skills_test.sh` and `check_traceability_test.sh` pass unchanged
- [x] Implement standard `skills/implement/SKILL.md` (six parts), listed in `marketplace.json` and the README [DES-001] (depends on: 2, 3) — check: each part present; lookup by `skills/{layer}/` path convention with no layer list; `tests/run.sh` passes
- [x] `agents/implement.md` as a thin wrapper preloading `compass-labs:implement`, owning `implement/` (root `tasks.md` in a past session); "near-empty" paragraph removed; `phase_agents_test.sh` assertions [DES-003] (depends on: 5) — check: `phase_agents_test.sh` passes with the new assertions; no "near-empty" text remains
- [x] Backend layer home `skills/backend/SKILL.md` and `skills/backend/reference/implement.md` (stack, tests, OpenAPI, API check), listed in `marketplace.json` and the README [DES-004] (depends on: 5) — check: (a) to (d) present; links `stack-defaults.md`, names no default stack; `stack_defaults_test.sh` passes; no `skills/frontend/` or `skills/database/`
- [x] Orchestrator Implement gate bullet in `skills/session/SKILL.md`: statuses and variations above the options, accept or rework per variation, one `decision` entry, no approval while rework is outstanding [DES-005] (depends on: 2) — check: `session_skill_test.sh` passes with a new assertion
- [x] `task-executor`: Phase 4 resolves `design/index.md` then root `design.md`, plan file `implement/tasks.md` or legacy root; Phase 5 links the standard's task rule; registry writes removed [DES-007] (depends on: 3, 5) — check: no `overview.md`, no registry-write instruction; fixture sessions in both design layouts resolve
- [x] Close fold-back of `implement/` in `close-foldback.md`: step 1 reads `implement/`, new Implement Diátaxis table, legacy root `tasks.md` as before [DES-006] (depends on: 3, 8) — check: new table with a Diátaxis column; `phase_agents_test.sh` fold-back assertions pass
- [x] Construct registration owned by Close alone (`close-foldback.md` registry bullet) and `post-hook-validator` triggered by name, reading the construct directly, lockfile only into a live session [DES-008] (depends on: 9) — check: registration instructions only in Close's procedure; a named run reads the construct
- [ ] Harness content tests: new `tests/session/implement_standard_test.sh` and `phase_agents_test.sh` updates covering the standard, the backend home, task-executor, the templates and `marketplace.json` [DES-010] (depends on: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11) — check: `tests/run.sh` exits 0

## Deviations from design

- **DES-011 is split across tasks 1 and 3, around DES-002.** `workflow_test.sh` requires a template for every file of a folder artifact, so `feature.json`'s new `implement/` entry can't land green before DES-002's templates exist. Task 1 does the plan lookups (no dependency on the templates), and task 3 lands `feature.json` with its guard and workflow tests once task 2 has added the templates. The design's implementation order is otherwise kept.
- **DES-001 part (5) cites "the layer's follow-up issue" without hard-coding #57, #58 and #59.** D3's option text names those issues, but listing them in the standard would make it a list of layer names to edit when a layer ships, which DES-001's Check and DES-010 rule out. The standard says to cite the layer's follow-up issue, and to open one if none exists.
- **The milestone gate's staging precondition (step d) had its example wording updated.** The delta list marks the gate's staging step unchanged, and its behaviour is: it still stages `feature.json`'s `phases[].artifact`. Only the example text changed, from `tasks.md` to the `implement/` folder with `tasks.md` as its legacy root file, so it no longer names a root `tasks.md` as a new session's Implement artifact. Done with DES-005, which edits the same gate.
- **DES-007 also converts `task-executor`'s worked example** (`examples/sample-feature/`) from `overview.md` plus a root `tasks.md` to `design/index.md` plus `implement/tasks.md`, and drops its integration-test task. The design names only `SKILL.md`, but the example is the skill's sample input and would otherwise show the retired `overview.md` layout. `scripts/run.sh` still mentions an `overview.md`: it's a stale personal cron wrapper with hard-coded local paths, which no instruction calls, so it's left as is and raised as a follow-up rather than changed here.
- **DES-007's Execute Phase 2 derives the session directory from an `implement/tasks.md` plan** by taking the plan folder's parent. The design doesn't mention it, but without it the `.validation-blocked` lockfile would be looked for inside `implement/`, not in the session folder where `post-hook-validator` writes it.
- **DES-008's search check is read as "a session's constructs" (REQ-018's wording).** Outside Close, `init` (bootstrapping a registry from existing code), `explore` (planned stubs) and `doc-maintainer`'s registry passes (R2 and R5, which survey existing code, and which run inside Close anyway per the design's Risks) still write construct stubs. None of them registers what a session built, so they're left as is. `task-executor` was the only other registrar of a session's constructs, and DES-007 removed it.
- **The README's `task-executor` artifact row and `post-hook-validator` paragraph were updated with DES-008**, so the README no longer describes a root `tasks.md` plan or a per-task registry write.
