---
session: 2026-08-19-session-lifecycle
type: feature
issue: 22
phase: implement
status: active
milestone: design
active_agent: main (orchestrator)
next_step: "User approves the Implement milestone (opens the PR, phase:implement → phase:test); then Test phase with claude --plugin-dir ."
---
# Session Log: Session Lifecycle (#22)

> Format: D2 (accepted 2026-09-24). Only the orchestrator writes this file; for now that's the main session. Entries are append-only.
> Artifacts: [`requirements.md`](requirements.md) (frozen) · [`design.md`](design.md) (frozen) · [`tasks.md`](tasks.md) · Follow-ups: #24–#32

## Open items

- Unconfirmed: `skills:` preload may not inject skill content when an agent runs as the main session (`--agent`). Evidence so far is only the model's own report. Agents have an explicit read-the-file fallback. Confirm before filing anything
- Testing must use `claude --plugin-dir .`: this Claude session loads compass-labs v1.0.0 from the plugin cache, so the repo's new hooks aren't active here
- Task 8: verify `claude --agent` works with a plugin-namespaced agent
- Deploy for this repo is a plugin release in a separate session (Q9). The version bump isn't part of Implement

## Key decisions

- **2026-09-24**: Atomic commits are a rule: one commit per decision/milestone entry and per ticked task. Enforced by a rule file plus a `Stop` commit guard (D8, REQ-016). A global rule was added to `~/.claude/rules/atomic-commits.md`.
- **2026-09-24**: ✅ Design milestone reached. D1a (one artifact per phase; an artifact can grow into a folder of native artifacts), D1b (ID links), D1c (EARS as the default; research in #32), D3 (three entry points, documented in the README), D5 accepted. No separate implementation guide: `tasks.md` is the Implement artifact.
- **2026-09-24**: D2 (log format), D4 (phase agent contract, including the Q6 amendment: only the orchestrator writes the log), D6 (fold-back + archive), D7 (enforcement hook) accepted.
- **2026-09-24**: ✅ Define milestone reached. C7 corrected: subagents can nest; the real limit is that they can't ask the user questions.
- **2026-09-24**: Deferred work goes into tracked issues (#24–#31), each linked back to this session.
- **2026-09-24**: Feature is the only session type for now. GitHub shows one milestone per SDLC phase. Archived sessions go to `docs/sessions/archive/`.
- **2026-09-24**: An orchestrator in the main session starts one subagent per phase. Define and Design are separate phases. Each file has one agent that writes it, except this log, which every agent writes to.
- **2026-09-24**: Reframed #22 from a design into a problem statement. The skill-driven design was dropped.
- **2026-08-19**: First design: the `plan` skill drives the whole session. The session file is created at Intake. *(Superseded.)*

---

## Phase: Define

### 2026-08-18 — Issue opened
- #22 opened after a design discussion. It proposed a 10-node lifecycle with `plan` as the only driver and 11 `stage:*` labels.

### 2026-08-19 — First spec (`plan` skill)
- `ce5721b`: spec written with 3 layers (state model, skill wiring, research agent).
- `27e8c1b`: `plan` skill changed so the session file is created at Intake, not after approval. **Still on the branch. Whether to keep it is a Design question.**

### 2026-09-24 — Review and first revision (dropped)
- Reviewed the branch: only one implementation step from the spec had been done.
- `a02a9ad`: tracked the leftover session docs, and ignored `graphify-out/` except `GRAPH_REPORT.md`.
- User raised two core problems: (1) skills are doing agent work and nothing closes the loop; (2) there's no session doc lifecycle, and the iteration record is mixed up with the as-built docs.
- Claude rewrote the spec as a four-subagent design. **Dropped (never committed).** User: "We are jumping into solutioning a little bit too quick." It didn't cover orchestration, different pacing per session type, a separate Define phase, or too many files.

### 2026-09-24 — Problem statement
- Spec rewritten as a problem statement only: current state, what's wrong, constraints, non-goals, open questions, success criteria.
- Evidence found: `hooks/validate-spec.sh` requires DB/Backend/Frontend sections, which neither session folder meets.

### 2026-09-24 — Decisions, round 1 (`e1e895e`)
- Q1 add an orchestrator · Q2 it runs in the main session · Q3 Define and Design are separate · Q5 the file set will evolve · Q6 one agent writes each file, except the log · Q7 fold back at close, then archive · Q8 state lives in the session folder · Q9 Deploy depends on the repo.
- New constraint C8: single responsibility. A file that keeps growing should be split.
- New problems added: 2.5 (each phase keeps a standard document up to date), 2.6 (the conversation must be recorded).

### 2026-09-24 — Decisions, round 2 (`a7f6fe1`)
- Q4 Feature only · Q10 the log records every handoff and decision so someone can pick up cleanly · Q11 start from `plan`/`adr`, then build one phase at a time · Q12 `docs/sessions/archive/` · Q13 one milestone per SDLC phase · Q14 deferred.
- New rule: future problems become GitHub issues linked back to this session.
- Follow-up issues created: #24 Bugfix, #25 Research, #26 Define, #27 Design, #28 Implement, #29 Test, #30 Deploy config, #31 Hook automation.

### 2026-09-24 — ✅ Milestone: Define complete
- Problem statement agreed. #22's description rewritten to match. Branch pushed.
- **Handoff:** Define → Design (both in the main session).

---

## Phase: Design

### 2026-09-24 — Design started
- Order: (1) session folder file set + log format, (2) orchestrator, (3) phase agent contract, (4) milestone mechanism, (5) fold-back and archive.

### 2026-09-24 — Platform check (docs: sub-agents, plugins-reference, workflows, hooks)
- **C7 was wrong:** subagents can nest up to 3 levels. `overview.md` corrected.
- **The real constraint:** subagents can't use `AskUserQuestion`, so Define and Design have to talk to the user through the main session. Q2 still holds, for a different reason.
- Workflows can't pause for user input mid-run and can only be resumed within the same Claude Code session. **Dropped as the orchestrator.** Kept as a candidate for fan-out inside a phase (#28/#29).
- Plugin agents ignore `hooks`/`permissionMode`, but plugin-level hooks fire inside subagents and report `agent_type`. That makes file-ownership enforcement possible (D7).

### 2026-09-24 — First design draft (`design.md`, D1–D7)
- D1: file set `problem.md` / `design.md` / `log.md` / `assets/`. Rename `overview.md` → `problem.md`.
- D2: log keeps state in frontmatter; entries append-only.
- D3: orchestrator as a command + skill (recommended) vs. a main-session agent.
- D4: phase agents return questions for the orchestrator to ask the user. **Proposed amendment to Q6:** only the orchestrator writes `log.md`, to avoid clashes from agents writing in parallel.
- D5: `phase:*` labels. D6: `git mv` to `archive/`. D7: `PreToolUse` hook enforcing the file set and file ownership.
- **Waiting on:** user decisions on D1–D7.

### 2026-09-24 — user — decision: design review round 1
- **Accepted:** D2 log format, D4 phase agent contract (including the Q6 amendment), D6 fold-back + archive, D7 enforcement.
- **Sent back:**
  - D1 is too thin: every SDLC phase should produce an artifact, even a thin one, and Define should produce requirements that follow a standard (via a requirements skill).
  - D3: can the user just start Claude as the orchestrator and pick new/previous sessions?
  - D5 is too thin: it isn't clear what actually gets implemented on GitHub.

### 2026-09-24 — main — attempt: design revision 2 (`design.md`)
- Checked: there's no `requirements` skill in the repo. `plan/template.md` is almost all design. `task-executor/template-tasks.md` works as the Implement artifact.
- D1 → one artifact per phase: `requirements.md` / `design.md` / `tasks.md` / `verification.md` / `release.md` + `log.md`. Linked by ID (REQ → DES → task → VER). Proposed standard: EARS + Given/When/Then + ISO 29148 quality checks. Each artifact is frozen at its milestone.
- D3 → one `session` skill with three ways in: repo default `agent` setting, `claude --agent compass-labs:orchestrator`, `/compass:session`. The list of sessions comes from a `SessionStart` hook, because plugin agents can't set `initialPrompt`.
- D5 → a table of GitHub actions per milestone, commit+push before each `gh` call, and an idempotent `gh-milestone.sh` that can catch up later. One issue + one branch/PR per session.
- D7 extended: also blocks writes to frozen artifacts (**needs user confirmation**, since D7 was already accepted).
- Added a "What gets built" section that separates what's in scope for #22 from what's in #26–#30.
- Converted this log to the D2 format.

### 2026-09-24 — user — decision: design review round 2
- **D1a accepted**, with a refinement: as phases mature, an artifact may become a folder of native artifacts (e.g. a Playwright report) that the MD file links to. Recorded on #29.
- **D1b, D1c accepted.** EARS is the default. Deeper research is deferred to **#32**.
- **D3 accepted.** All three entry points go in the README.
- **D5 accepted.** No objection to the D7 freeze extension or the Q6 amendment.
- User asked: "Do you need a separate implementation guide, or can we proceed?" Answer: no separate guide. By D1, `tasks.md` is the Implement artifact.

### 2026-09-24 — main — note: Define artifact brought in line with D1
- Renamed `overview.md` → `requirements.md`, and rewrote the success criteria as REQ-001 to REQ-015 (EARS + Given/When/Then). The problem statement and decisions are unchanged. This was done under this entry's decision; the guard doesn't exist yet.
- Added a traceability table to `design.md` (D1–D7 → REQ).

### 2026-09-24 — main — milestone: ✅ Design complete
- `design.md` frozen. `tasks.md` created (13 tasks, task-executor format, each tagged with D-ids and REQ-ids).
- **Handoff:** Design → Implement (main session, manual).

### 2026-09-24 — user — decision: atomic commits as an enforced rule
- User: every artifact agreed in discussion, and every complete set of requirements, gets its own commit, not one commit per session. Every task ticked off gets its own commit.
- Checked the Claude Code docs: the equivalent of Cursor rules is `.claude/rules/*.md` (with optional `paths:`), but it only guides Claude. Hooks enforce. `Stop` exit 2 blocks the end of a turn; there's no documented loop guard. Plugins can't ship rules.
- Added: global `~/.claude/rules/atomic-commits.md` (user level, outside the repo), project `.claude/rules/compass-sessions.md` (`c529906`), **REQ-016**, **D8**, task 14.
- This entry changes frozen artifacts (`requirements.md`, `design.md`) under this logged decision.

---

## Phase: Implement

### 2026-09-24 — main — handoff: orchestrator → implement agent (batch 1: tasks 1–3)
- **From → To:** main (orchestrator) → Sonnet subagent acting as `compass-labs:implement` (the plugin agent doesn't exist yet)
- **Input:** session path, tasks 1–3, D4 rules (write only `tasks.md` + code, no log/frozen docs, one commit per task, no push)
- **Output:** `23978ac`, `03749b3`, `0d97354`; `bash tests/run.sh` 1/1 pass

### 2026-09-24 — implement — attempt: artifact templates built (`23978ac`)
- `skills/session/templates/{requirements,design,tasks,verification,release,log}.md` per the D1 table. REQ/DES/VER ID conventions. The log template follows D2.

### 2026-09-24 — implement — attempt: Feature workflow defined as data (`03749b3`)
- `skills/session/workflows/feature.json`: flat `phases[]` (phase, order, owner_agent, artifact, milestone, gh_label, conversational) + `session_level` (file allowlist, log owner). It's JSON because hooks are bash + `jq` (no `yq`). The agent logged this as a deviation. **Orchestrator review: not a real deviation**, since D3 says "`feature.yaml`-style" and the build table says `feature.*`.

### 2026-09-24 — implement — attempt: test harness built (`0d97354`)
- `tests/run.sh` (runs `tests/**/*_test.sh`), `tests/lib.sh` (hook stdin/exit/stderr assertions, temp git repo + session fixtures), `tests/session/workflow_test.sh`.

### 2026-09-24 — main — note: batch 1 review
- Verified: one task per commit, correct file scope, tests pass when rerun by the orchestrator.
- **Found for task 4:** the frontmatter `milestone` isn't consistent (`define` in the real log, `none` in the template, `"Define complete"` in `feature.json`). The guard needs a phase key to work out frozen artifacts. Decision for batch 2: `milestone` holds the **phase key** of the last completed milestone (`none` | `define` | … | `close`), and `feature.json` `milestone` stays a display label.

### 2026-09-24 — main — handoff: orchestrator → implement agent (batch 2: tasks 4–6)
- **Input:** tasks 4–6 + the orchestrator's decision that frontmatter `milestone` holds the phase key.
- **Output:** `5585114`, `79641d3`, `9da8d97`; `bash tests/run.sh` 5/5 pass.

### 2026-09-24 — implement — attempt: guard hook built (`5585114`)
- `hooks/session-guard.sh` (PreToolUse `Write|Edit|MultiEdit`): archive read-only, only `log.md` allowed before a session's log exists, file allowlist from the workflow JSON, `assets/` non-Markdown only, ownership via `agent_type`, `log.md` orchestrator-only, frozen artifacts (subagents always blocked; main session only with an uncommitted `decision` entry). Allows the write with a warning if `jq` or the workflow file is missing. The log template now documents `milestone` as a phase key.

### 2026-09-24 — implement — attempt: GitHub milestone scripts built (`79641d3`)
- `gh-setup.sh`, `gh-milestone.sh`: safe to re-run (hidden comment marker); print `SYNC_PENDING` and exit 0 on failure. `feature.json` gained `github` + per-phase `gh_color` (recorded as a deviation). Tests use a stub `gh`.

### 2026-09-24 — implement — attempt: orchestrator skill + traceability gate built (`9da8d97`)
- `skills/session/SKILL.md` (90 lines), `check-traceability.sh` (REQ-011).

### 2026-09-24 — main — note: batch 2 review, 2 defects
- **Defect 1, guard path traversal:** `docs/sessions/s1/assets/../notes.txt` → exit 0 (allowed), while `…/s1/notes.txt` → exit 2. The `cd`-based path cleanup fails when a folder doesn't exist yet, so `..` survives. Fix: resolve `.`/`..` as text.
- **Defect 2, repo-relative paths in `SKILL.md`:** script and template paths (`bash skills/session/scripts/…`) only work inside compass-labs. In a repo that installs the plugin they must resolve from the plugin root (as `task-executor` does). Breaks REQ-001 outside this repo.
- Otherwise accepted. Noted for later: the subagent flagged that `session-commit-guard` (task 14) should share the "uncommitted decision entry" check with `session-guard`, and that `check-traceability.sh` depends on column order (#29).
- The session loads plugin v1.0.0 from the cache, so the new hooks aren't active here. Test phase: `claude --plugin-dir .`.

### 2026-09-24 — main — handoff: orchestrator → implement agent (batch 3: 2 fixes + tasks 7–9)
- **Output:** `520ba57`, `b847ac2`, `59eafd3`, `f4b547a`, `691b713`; `bash tests/run.sh` 8/8 pass.

### 2026-09-24 — implement — attempt: guard path-traversal fix (`520ba57`)
- Path cleanup is now done as text in pure bash (no filesystem dependency); `cwd` is resolved physically to match git's toplevel. 4 regression tests.

### 2026-09-24 — implement — attempt: plugin-root paths in SKILL.md (`b847ac2`)
- Every plugin path is now `${CLAUDE_PLUGIN_ROOT}/skills/session/…`. `docs/sessions/…` paths stay repo-relative.

### 2026-09-24 — implement — attempt: SessionStart hook (`59eafd3`)
- `hooks/session-start.sh` lists active/paused sessions (never `archive/`) for the orchestrator only. Always exits 0. 7 tests.

### 2026-09-24 — implement — attempt: entry points (`f4b547a`)
- `agents/orchestrator.md` + `commands/session.md`. `claude --plugin-dir . --agent compass-labs:orchestrator -p …` → `ORCHESTRATOR_OK session`. **P8 confirmed.** The agent said the `skills:` preload content wasn't in its context, so an explicit read-the-file fallback was added and re-checked.

### 2026-09-24 — implement — attempt: thin phase agents (`691b713`)
- `agents/{define,design,implement,test,deploy,close}.md`. Shared D4 contract in `skills/session/reference/phase-agent-contract.md`, read explicitly. Tools scoped per phase; Close preloads `doc-maintainer`.

### 2026-09-24 — main — note: batch 3 review
- Checked: commits scoped correctly, 8/8 tests pass on rerun, and the traversal probe is now blocked (exit 2).
- **Measured the `agent_type` of a plugin subagent**, because the docs summary claimed `plugin:compass-labs:<name>`. Headless run with a temporary SubagentStart/PreToolUse logging hook: `{"agent_type":"compass-labs:implement"}` for both events. It matches `feature.json` `owner_agent`, so guard ownership works for real phase agents.
- The preload finding is recorded as **unconfirmed** (model self-report, `--agent` main-session mode only). Not filed as an issue yet.

### 2026-09-24 — main — handoff: orchestrator → implement agent (batch 4: tasks 10–14)
- **Output:** `a541727`, `997ce1d`, `3c216c1`, `74cf0dc`, `57678f4`; `bash tests/run.sh` 13/13 pass; `tasks.md` 14/14 ticked.

### 2026-09-24 — implement — attempt: requirements/verification skills (`a541727`)
- `skills/requirements/` (EARS, REQ-nnn, 29148 checklist) and `skills/verification/` (VER table; warns that its column order is relied on by `check-traceability.sh`). Preloaded by the Define and Test agents.

### 2026-09-24 — implement — attempt: Close fold-back + archive ordering (`997ce1d`)
- `reference/close-foldback.md`, `scripts/archive-session.sh`. The Close milestone order in SKILL.md: log entry + `status: archived` → commit → `git mv` → commit → push → gh. Also fixed task 9's `close.md`, which had the Close agent doing the `git mv` itself (it can't, because the orchestrator must commit `status: archived` first).

### 2026-09-24 — implement — attempt: `validate-spec.sh` retired (`3c216c1`)
- The whole script and its PostToolUse entry are removed. The session-folder check was all the script did.

### 2026-09-24 — implement — attempt: docs (`74cf0dc`)
- README "Using Sessions in a Repo" (three entry points, settings snippet, hook table). `CLAUDE.md` directory rules now include `agents/` and `tests/`.

### 2026-09-24 — implement — attempt: Stop commit guard + rule template (`57678f4`)
- `hooks/session-commit-guard.sh` (Stop) blocks on an uncommitted `decision`/`milestone` heading. Loop guard: a counter per `session_id`; the 3rd attempt in a row is allowed. `stop_hook_active` isn't documented for Stop, so the counter is the real guard. Shared helper `hooks/lib/session-log.sh`, now also used by `session-guard.sh`. Generalized rule template; SKILL.md setup copies it if missing.

### 2026-09-24 — main — note: batch 4 review; Implement ready for milestone gate
- Checked: commit scope, 13/13 tests pass on rerun, 14/14 tasks ticked, `hooks.json` = SessionStart + PreToolUse + Stop, README/CLAUDE.md changes only add content.
- **Not logged as a milestone:** the agent proposed "Implement complete", but a milestone needs user approval at the gate, and D5 requires an open PR.
- Carried to Test (from the agent's notes): a live `claude --plugin-dir .` smoke test of all three hooks through Claude Code itself; `--agent` resolution for every phase agent; a clean re-test of the `skills:` preload question; a full Close sequence in a throwaway session; no cleanup yet for the commit guard's counter files in `$TMPDIR`.
