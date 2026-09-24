---
issue: 22
branch: feat/session-lifecycle
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

- [x] Artifact templates: thin `requirements`, `design`, `tasks`, `verification`, `release`, `log` in `skills/session/templates/` [D1, D2 · REQ-014, REQ-007]
- [x] Feature workflow definition as data (`skills/session/workflows/feature.json`: phases, owner agent, artifact, milestone) [D3 · REQ-002]
- [x] Test harness `tests/run.sh` (plain bash, no dependencies) that feeds sample hook JSON to hook scripts and checks exit codes (depends on: 1)
- [x] Guard hook `hooks/session-guard.sh` + `hooks.json` PreToolUse `Write|Edit` entry: file set, ownership via `agent_type`, frozen artifacts via `log.md` frontmatter, archive. Includes tests [D7 · REQ-004, REQ-005, REQ-006] (depends on: 2, 3)
- [x] GitHub scripts `skills/session/scripts/gh-setup.sh` (labels, idempotent) and `gh-milestone.sh` (label swap + comment, idempotent, logs a pending sync and exits 0 on failure) [D5 · REQ-009, REQ-010]
- [x] Orchestrator skill `skills/session/SKILL.md`: new / resume / status, main loop, question relay, milestone gate (commit → push → gh), follow-up issue creation, REQ↔VER check at the Test milestone [D3, D4, D5 · REQ-001, REQ-002, REQ-003, REQ-008, REQ-011, REQ-013] (depends on: 1, 2, 5)
- [ ] SessionStart hook `hooks/session-start.sh`: when `agent_type` is the orchestrator, list sessions with `status: active|paused` from `log.md` frontmatter. Includes tests [D3 · REQ-008, REQ-015] (depends on: 1, 3)
- [ ] Entry points `agents/orchestrator.md` (thin: `skills: [session]`) + `commands/session.md`. Verify `claude --agent compass-labs:orchestrator` resolves; if not, log a deviation [D3 · REQ-015] (depends on: 6)
- [ ] Thin phase agents `agents/{define,design,implement,test,deploy,close}.md`: D4 contract, restricted tools, preloaded skill [D4 · REQ-002, REQ-003] (depends on: 6)
- [ ] Thin `requirements` skill (EARS + Given/When/Then + ISO 29148 checks) and thin `verification` skill (VER table format) [D1c, D1 · REQ-014] (depends on: 1)
- [ ] Close agent fold-back: `doc-maintainer` pass, "Origin: #N" line, `git mv` to `docs/sessions/archive/`, `status: archived` [D6 · REQ-012] (depends on: 9)
- [ ] Retire the session-folder check in `hooks/validate-spec.sh` (replaced by the guard). Leave `plan` itself alone (#26/#27) [D7] (depends on: 4)
- [ ] Docs: `CLAUDE.md` directory rules (add `agents/`), README "Using sessions in a repo" (three entry points + default-agent snippet) [D3 · REQ-015] (depends on: 8)
- [ ] Commit guard `hooks/session-commit-guard.sh` + `hooks.json` Stop entry (uncommitted decision/milestone entry → exit 2; allow after 2 blocks in a row). Includes tests. Rule template `skills/session/templates/rules/compass-sessions.md`, which the setup step copies to `.claude/rules/` [D8 · REQ-016] (depends on: 3, 6)

## Deviations from design

- **Task 2**: workflow definition is `skills/session/workflows/feature.json`, not `feature.yaml` as task 2's own text and design.md's D3 mention it. Per the implement-agent brief: hooks are bash and `jq` is available in this repo, `yq` is not, so JSON keeps later hook tasks (4+) dependency-free. Schema is flat (`phases[]` with `phase`, `order`, `owner_agent`, `artifact`, `milestone`, `gh_label`, `conversational`, plus a `session_level` block for the D1 file allowlist and log ownership) so `jq '.phases[] | select(.phase=="…")'` is enough for later hooks. No separate README — the schema is documented via a `"$comment"` field inside the JSON. *(Orchestrator review, batch 1: not a real deviation — D3 says "yaml-style" and the build table says `feature.*`.)*
- **Task 5**: extended `feature.json` (from task 2) with a `github` block (`type_label`, `type_color`) and a `gh_color` per phase, using the colors from design.md's D5 one-time-setup snippet. Not in task 2's or task 5's original scope, but `gh-setup.sh` needs label colors from somewhere and the workflow file already carries every other `gh_label`, so colors moved in beside them rather than being hard-coded in the script.
