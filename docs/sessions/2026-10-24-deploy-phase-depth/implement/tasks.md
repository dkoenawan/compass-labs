---
issue: 30
branch: feat/30-deploy-phase-depth
status: in-progress
test_command: bash tests/run.sh
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

- [x] Write the Deploy standard `skills/deploy/SKILL.md`: the two lifecycles, the declaration's seven items, the execution rules, the L1 rule, the tier table, the release session (D5), and a description that names the starter [DES-001]
- [x] Write `skills/deploy/reference/declaration.md` (field table, `run` placeholders, a full example for each mode) and `skills/deploy/reference/frameworks.md` (D10 verdicts) [DES-001] (depends on: 1)
- [x] List the Deploy standard in `.claude-plugin/marketplace.json` and `README.md`, with `tests/session/deploy_standard_test.sh` [DES-001] (depends on: 1, 2) — check: `tests/session/marketplace_test.sh` passes with the skill listed; each tier has its risk and seven section rows; rollback and change record each name a framework and verdict
- [x] Add the Deploy-only clause to `skills/session/reference/phase-agent-contract.md`, with its content test [DES-005] — check: the clause is present and doesn't relax rule 1 or 2 for the session folder; the guards' tests still pass unchanged
- [x] Write the starter script `skills/deploy/templates/github/release-tag.sh [--check]` with its settings block, and `tests/session/release_tag_test.sh` [DES-008] — check: component tests on a copy filled in with compass-labs' values, against a bare local repo and a stub `gh`: version changed, unchanged, tag exists (the tag doesn't move), `--check` creates no tag and no release, and a plain-text `VERSION` file
- [x] Write `.github/scripts/bump-version.sh <patch|minor|major>` and `tests/session/bump_version_test.sh` [DES-010] — check: `2.2.1` with `minor` gives `2.3.0`; a bad level exits 1 and changes nothing
- [x] Build the four fixture repos under `tests/fixtures/deploy/` (declarations, switchable `check-health.sh`, `fixture-new-part`'s design delta list) [DES-013] (depends on: 1, 2, 3)
- [x] Write `skills/deploy/scripts/check-declaration.sh <repo-root>` validation, with `tests/session/check_declaration_test.sh` [DES-002] (depends on: 1, 2, 3, 7)
- [x] Add `--plan` to `check-declaration.sh`, with its tests [DES-002] (depends on: 8) — check: component tests on all four fixtures: `fixture-no-declaration` reports no declaration; a `fixture-service` copy with no rollback names "rollback"; production steps never appear as may-run; the tier matches the tier table; a tag form without `{version}` is named; no repo command runs
- [x] Rewrite the release template `skills/session/templates/release.md` (tier line, seven sections), with its test [DES-003] (depends on: 1, 2, 3) — check: the template's headings match the standard's tier table and `check-release.sh`'s list
- [x] Write the starter workflow `skills/deploy/templates/github/release.yml`, with `tests/session/release_workflow_test.sh` [DES-009] (depends on: 5) — check: no `dkoenawan/compass-labs`, no `CLAUDE_PLUGIN_ROOT`, both triggers and both permission sets present
- [x] Rewrite the Deploy agent `agents/deploy.md` to preload `compass-labs:deploy` and follow the Deploy process flow, with its content test [DES-004] (depends on: 1, 2, 3, 4, 8, 9, 10)
- [x] Write `skills/session/scripts/check-release.sh <session-dir>` and `tests/session/check_release_test.sh` [DES-006] (depends on: 1, 2, 3, 10) — check: full tier with no rollback prints "rollback missing", exit 1; every tier passes when complete; an old-layout record passes
- [x] Write compass-labs' declaration `.claude/deploy.json`, with its test [DES-011] (depends on: 1, 2, 3, 6, 8, 9) — check: `check-declaration.sh` reports valid on it; the four steps are routine and the merge is production-affecting; the pipeline part is listed
- [x] Write `skills/deploy/scripts/install-starter.sh <repo-root>` and `tests/session/install_starter_test.sh` [DES-015] (depends on: 1, 2, 3, 5, 8, 9, 11) — check: GitHub `origin` writes both files with `fixture-service`'s values and no `dkoenawan/compass-labs`; a non-GitHub `origin` writes nothing; an existing workflow file is left byte-for-byte unchanged; a missing `versioning.tag` is named
- [ ] Add the tier confirmation, `check-release.sh` and the Deploy `needs_input` relay to the Deploy gate in `skills/session/SKILL.md`, and list the script [DES-007] (depends on: 13)
- [ ] Remove `release`, `_bump-version`, `_tag-and-push` and `_update-cache` from `Taskfile.yml` and point `check-upgrade`'s hint at the D4 commands [DES-012] (depends on: 14) — check: `task --list` shows no `release`, and `task check-upgrade` runs with the new hint
- [ ] Write the "Declaration offer" procedure and the `starter` mode in `skills/deploy/SKILL.md` [DES-014] (depends on: 1, 2, 3, 8, 9, 15)
- [ ] Call the declaration offer from `skills/init/SKILL.md` (greenfield and brownfield, before the commit) and from `skills/session/SKILL.md` one-time setup (new step 3) [DES-014] (depends on: 18)
- [ ] Make the starter's `--check` note an unchanged version instead of warning that the merge would fail on an existing tag, with its test case [DES-008] (depends on: 5) — check: `tests/session/release_tag_test.sh` passes every DES-008 case, plus an unchanged version with an existing tag
- [ ] Install compass-labs' pipeline by running `install-starter.sh` on this repo, writing `.github/workflows/release.yml` and `.github/scripts/release-tag.sh`, with `tests/session/own_pipeline_test.sh` [DES-016] (depends on: 14, 15, 20) — check: the files match a fresh `install-starter.sh` run into a temp copy
- [ ] Map each fixture to the criteria it serves in `tests/fixtures/deploy/README.md`, with `tests/session/deploy_fixtures_test.sh`, and run the full harness [DES-013] (depends on: 5, 6, 7, 9, 13, 15) — check: `tests/run.sh` passes
