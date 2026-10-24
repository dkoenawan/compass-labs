---
session: 2026-10-17-session-branch-on-open
type: feature
issue: 37
phase: close
status: archived
# milestone: the PHASE KEY of the last completed milestone, not a display
# label. Allowed values (feature workflow): none | define | design |
# implement | test | deploy | close. "none" until the first milestone
# (Define complete) is reached. The guard hook (D7) uses this key, plus
# each phase's `order` in workflows/<type>.json, to decide which
# artifacts are frozen. Display labels (e.g. "Define complete") live only
# in workflows/<type>.json's `milestone` field, for GitHub comments.
milestone: close
active_agent: none
next_step: "None — session closed; fold-back reaches main with the next session branch (#66)"
---
# Session Log: Session opens on a feature branch (#37)

> Format: D2. Only the orchestrator writes this file. Entries are append-only.
> Artifacts: [`define/index.md`](define/index.md) · [`design/index.md`](design/index.md) · [`implement/`](implement/) · [`verification.md`](verification.md) · [`release.md`](release.md)

## Open items

- Follow-ups: #70 no remote / failed push; #72 Close closes the issue before the PR is merged; #73 branch guard stops applying once a session is archived; #74 stale README and docs/index.html; #75 guard message names REQ-005.
- Work is on branch `feat/37-session-branch-on-open`; it reaches main through a PR.

## Key decisions

- **2026-10-24**: ✅ Session closed — #37 shipped in PR #71 (v2.2.0); fold-back in docs/ and ADR-006; follow-ups #70, #72, #73, #74, #75.
- **2026-10-24**: Follow-ups filed — #74 stale README line and docs/index.html, #75 guard block message names REQ-005.
- **2026-10-24**: ✅ Deploy complete — v2.2.0 prepared on the session branch; no manifest gaps; PR #71 marked ready. Merge, tag and cache refresh are the user's after merge.
- **2026-10-24**: Release as v2.2.0 (MINOR) — the default-branch block is intended behaviour, not a breaking interface change.
- **2026-10-24**: README hook table lists session-branch-guard.sh before the merge.
- **2026-10-24**: ✅ Test complete — VER-001 to VER-013 pass for REQ-001 to REQ-010; VER-014 (live orchestrator runs) left pending by the user's choice.
- **2026-10-24**: Test's integration script kept in the harness as tests/integration/session_branch_integration_test.sh.
- **2026-10-24**: Follow-up filed — #73 branch guard stops applying once a session is archived.
- **2026-10-24**: ✅ Implement complete — DES-001 to DES-009 built (6 as designed, 3 with accepted variations); 24 tests pass.
- **2026-10-24**: Implement gate — V1, V2 and V3 accepted as built; no rework.
- **2026-10-20**: ✅ Design complete — DES-001 to DES-009 cover REQ-001 to REQ-010; D1–D6 recommended options; #72 deferred.
- **2026-10-20**: D1–D6 take the recommended options; Close's issue-closing gap filed as #72.
- **2026-10-19**: ✅ Define complete — REQ-001 to REQ-010 approved (8 Must, 2 Should); no open questions.
- **2026-10-17**: Short tier and problem agreed for #37 — need: session work reaches the default branch only via PR; hook-enforced; OUT-01 zero direct commits over the next 3 sessions; anchor aligns, no update.
- **2026-10-19**: Open questions answered — PR opens as a draft at the first push (REQ-008); ask about an existing branch (REQ-002); block session commits only (REQ-005).
- **2026-10-17**: Follow-up filed — #70 branch guard with no remote or a failed push (out of #37's scope).
---

## Phase: Define

### 2026-10-17 — main — note: Session opened
- Issue #37 picked by the user. Branch `feat/37-session-branch-on-open` created from main (b1c2bcc) before the first commit, done by hand since this is the gap the session fixes.

### 2026-10-17 — main — handoff: orchestrator → compass-labs:define (frame #37)
- **Input:** Frame issue #37 (new session flow must branch before its first commit/push), propose a depth tier, and draft requirements once the problem is agreed. Context: #23 pushed d38c99c to main and had to revert it (912634c); this session's branch was created by hand.
- **Output:** needs_input; no files changed (tier, need, stakeholders, scope edges, guarantee strength, success outcome asked)

### 2026-10-17 — compass-labs:define — note: Framing checks run for #37; tier and need awaiting the user
- Proposed tier: short. It's a focused change to the New session flow, with a documented incident and no new phase or artifact.
- Symptom: `d38c99c` pushed to origin/main in #23 and reverted in `912634c` (archived #23 log, lines 102–116). Cause (shown): SKILL.md step 4 commits and pushes with no branch step, #22's D5 put branch creation at Implement, and no hook checks the target branch.
- Anchor complete. Draft verdict aligns (Scope: hooks and scripts that enforce session structure; works in any repository). Anchor update: none.
- Overlaps: no construct or ADR conflict found. #22's design D5 ("branch created at Implement") would change.
- XY: the issue's branch fix is held as a candidate until the user confirms the need (Q2).
- Asked: tier, need, stakeholders, scope edges (non-default branch, resume, PR timing, no remote), how strong the guarantee must be, and the success outcome.

### 2026-10-17 — main — decision: Follow-up filed — #70 no remote or failed push
- The user left "repos with no remote, or where the push fails" out of #37's scope. Filed as #70 (parent #37).
- Answers relayed to Define: tier short; need = session work reaches the default branch only through a PR; stakeholders = compass-labs maintainers and teams using the plugin in other repos; guarantee = blocked by a hook; in scope: already on a branch, resume on the default branch, opening the PR; OUT-01 target zero, watched over the next 3 sessions.

### 2026-10-17 — compass-labs:define — decision: Short tier and problem agreed for #37
- The user confirmed tier short.
- Need (a): session work reaches the default branch only through a PR. Branching at open is a candidate solution.
- Stakeholders: compass-labs maintainers (NEED-01) and teams using the plugin in other repos (NEED-02).
- In scope: opening on a non-default branch, resuming with the default branch checked out, and opening the PR as an explicit step. Out of scope: no remote or a failed push, a non-goal tracked by #70.
- Constraint: the guarantee must be enforced by a hook, not prompt instructions alone (ADR-002).
- OUT-01: 0 session commits on the default branch except through a PR merge. Checked at Test in a throwaway repo, then over the next 3 sessions.
- Anchor: complete, verdict aligns, update none. Overlaps: none, apart from #22's design D5 (branch at Implement), which this work changes.

### 2026-10-17 — compass-labs:define — attempt: Draft requirements REQ-001 to REQ-010 for review
- requirements.md has 10 live rows (8 Must, 2 Should) and no deferred rows. OUT-01 is covered.
- Open questions in index.md: when the PR opens (REQ-008), whether to ask about an existing branch (REQ-002), and how wide the block is (REQ-005).

### 2026-10-19 — main — decision: Open questions answered for #37
- REQ-008: the pull request opens as a draft as soon as the session branch is first pushed, after asking the user. REQ-008 is rewritten in place (still a draft); the Deploy-gate timing and the #22 D5 timing are dropped.
- REQ-002: kept. The orchestrator asks each time, because asking is cheap.
- REQ-005: kept. The block covers session commits only.
- index.md: open questions moved to a Decisions section; none remain.

### 2026-10-19 — main — milestone: ✅ Define complete
- The user approved define/requirements.md: REQ-001 to REQ-010 (8 Must, 2 Should), none deferred. Open questions: all resolved.
- Anchor check (a3): action none, nothing to write.
- Carried into Design: REQ-008 asks once, at the first push; if the user declines, no later prompt is required. #22's D5 (branch at Implement) is superseded and Close folds the change into `docs/explanation/session/overview.md`.

---

## Phase: Design

### 2026-10-19 — main — handoff: orchestrator → compass-labs:design (design #37)
- **Input:** Turn the frozen REQ-001 to REQ-010 into design/ (classification, scope check, context view, delta list, DES items, decisions, principles check). Carried from Define: REQ-005's block must be a hook (ADR-002) covering session commits only; the default branch is read from the repo (REQ-006); REQ-008 asks once at the first push to open a draft PR; #22's D5 (branch at Implement) is superseded.
- **Output:** needs_input; design/index.md (Prior knowledge, Classification, Scope checklist drafted; rest pending). Asked: primary kind, scope checklist.

### 2026-10-19 — compass-labs:design — note: Design classification and scope drafted for #37
- Prior knowledge read: session overview, hooks-and-scripts reference, patterns, ADR-002, the session skill, the hooks, feature.json, the log template, the tests layout, and this session's define/ and log.md. No past session folder was read.
- Proposed kind: Plugin/tooling (no in-depth path, dkoenawan/compass-labs#51).
- Proposed scope, in: plugin/tooling, process/workflow, gh integration, harness tests. Out: frontend, backend, database, infrastructure, visual UI and as-built docs (Close's job).
- Waiting for the user to confirm the kind and scope.

### 2026-10-20 — main — decision: Classification and scope confirmed for #37
- The user confirmed the primary kind, Plugin/tooling (no in-depth path, #51), so the whole design stays in design/index.md.
- The user confirmed the scope. In: plugin/tooling, process/workflow, gh integration, harness tests. Out: frontend, backend, database, infrastructure, visual UI and as-built docs.

### 2026-10-20 — compass-labs:design — attempt: Design for #37 drafted; D1 to D6 await the user
- design/index.md: Context view (C4 component view and a New session process flow), Delta list, DES-001 to DES-009, Decisions D1 to D6, Principles check, Risks and Open questions.
- DES-001 default-branch.sh; DES-002 list-sessions.sh; DES-003 session-branch-guard.sh (PreToolUse Bash hook); DES-004 log.md `branch:` field; DES-005 New session branch step; DES-006 first push and one-time draft PR prompt; DES-007 Resume switches to the session branch; DES-008 session-start lists sessions on other branches; DES-009 no-merge rule.
- Coverage: all 10 live REQs covered. No principle traded off. Mermaid blocks parse (mermaid-cli 12).
- Asked: D1 enforcement mechanism, D2 what counts as a session commit, D3 where the branch is recorded, D4 how Resume finds a session on another branch, D5 where a new branch starts, D6 default-branch lookup, and whether Close's issue-closing step needs a follow-up issue.

### 2026-10-20 — main — note: Dark-mode text colour added to #37's design diagrams
- The user couldn't read the diagrams in dark mode. Both flowcharts' delta classDefs now set `color:#0F172A`, ahead of the standard fix tracked in #66. This departs from `skills/design/reference/notations.md` until #66 lands.
- Both diagrams render with mermaid-cli 12.

### 2026-10-20 — main — decision: D1 to D6 take the recommended options; Close gap filed as #72
- The user approved the design draft ("looks good"), which takes the recommended option in each decision: D1 (a) PreToolUse Bash hook, D2 (B) a working-tree session, staged docs/sessions/ files or an active session at any local branch tip, D3 (a) `branch:` in log.md frontmatter, D4 (a) read every local branch, D5 (a) new branch from the local default branch tip, D6 (a) origin/HEAD then git ls-remote.
- Close step 6's issue closing while the PR may still be open is out of #37's scope: filed as #72 (parent #37).

### 2026-10-20 — compass-labs:design — decision: Design decisions D1 to D6 chosen for #37
- The user chose the recommended option in each: D1 a PreToolUse hook on Bash (ADR candidate for Close); D2 B, a session counts as active if it's in the working tree, staged under docs/sessions/, or at the tip of any local branch; D3 a `branch:` field in log.md's frontmatter; D4 Resume and listing scan local branches; D5 a new branch starts from the local default branch's tip; D6 `origin/HEAD`, then `git ls-remote --symref origin HEAD`.
- Close's issue-closing step, with the PR possibly still open, is deferred to #72 (parent #37) and recorded as a follow-up in design/index.md.

### 2026-10-20 — compass-labs:design — attempt: Design for #37 ready for the gate
- design/index.md finished: Status set to ready for the gate, decisions marked chosen with reasons, and Open questions cut to the #51 and #49 no-in-depth-path note.
- DES-001 to DES-009 cover all 10 live REQs. No principle traded off. check-design.sh passes, and both Mermaid blocks parse.

### 2026-10-20 — main — milestone: ✅ Design complete
- The user approved the design ("looks good, implement and test away and deploy"). check-design.sh: ok.
- design/ frozen: DES-001 to DES-009, D1 to D6 (recommended options), all 10 live REQs traced. Follow-up #72.
- The user asked to run Implement, Test and Deploy, and to be told when the PR is ready to merge.

---

## Phase: Implement

### 2026-10-20 — main — handoff: orchestrator → compass-labs:implement (implement #37)
- **Input:** Turn frozen design/index.md DES-001 to DES-009 into implement/tasks.md and implement/as-built.md, in the design's build order, with unit and component tests in the tests/run.sh harness; commit per task.
- **Output:** done; implement/tasks.md, implement/as-built.md, 3 new scripts/hooks, 4 changed source files, 3 new and 2 extended test files (commits 3077870..c1e4302).

### 2026-10-20 — compass-labs:implement — attempt: Implement built DES-001 to DES-009 for #37
- Planned 9 tasks in implement/tasks.md from the design's DES table and built them in its order (DES-001, 002, 004, 009 → 003, 005, 007, 008 → 006), one commit per ticked task, each pushed to feat/37-session-branch-on-open.
- New: default-branch.sh, list-sessions.sh, hooks/session-branch-guard.sh (PreToolUse, matcher Bash, in hooks.json). Changed: session-start.sh, templates/log.md (branch:), skills/session/SKILL.md, agents/orchestrator.md.
- Tests: default_branch_test.sh, list_sessions_test.sh, session_branch_guard_test.sh (new); session_start_test.sh, session_skill_test.sh (extended). bash tests/run.sh: 24 passed, 0 failed.

### 2026-10-20 — compass-labs:implement — note: as-built.md ready for the Implement gate
- As-built has a row for every DES item: 6 built as designed, 3 built with variation (DES-002 V1, DES-003 V2, DES-008 V3), none not built. Each variation needs accept or rework at the gate.
- Handed to Test: the DES-003 and DES-008 integration checks (real hook with the real scripts), and the live checks for DES-005, 006, 007 and 009.

### 2026-10-24 — main — decision: Implement variations V1 to V3 accepted as built
- The user accepted every variation in implement/as-built.md ("continue away"): V1 (DES-002 branch-copy tie-break and working-tree "found on") accepted; V2 (DES-003 extra command and push forms, fail open when a collaborator is missing) accepted; V3 (DES-008 folder-name slug, silent when the lister is missing) accepted. No rework.

### 2026-10-24 — main — milestone: ✅ Implement complete
- The user approved the Implement gate. As-built: DES-001 to DES-009 all built; 6 as designed, V1 (DES-002), V2 (DES-003) and V3 (DES-008) accepted. bash tests/run.sh: 24 passed, 0 failed.
- implement/ frozen. Handed to Test: integration checks for DES-003 and DES-008, live checks for DES-005, 006, 007 and 009.

---

## Phase: Test

### 2026-10-24 — main — handoff: orchestrator → compass-labs:test (verify #37)
- **Input:** Verify REQ-001 to REQ-010 into verification.md (VER-* per REQ); include the integration checks for DES-003 and DES-008 (real hook with the real scripts) and the live checks for DES-005, 006, 007 and 009 handed over by Implement.
- **Output:** done; verification.md (VER-001 to VER-014)

### 2026-10-24 — compass-labs:test — attempt: Verification for #37 ready for the Test gate
- verification.md has VER-001 to VER-014. VER-001 to VER-013 pass, covering REQ-001 to REQ-010; check-traceability.sh exit 0. `bash tests/run.sh` gave 24/24 at 031f7ac.
- A scratch integration script (70/70) ran the real guard, session-start, default-branch, list-sessions and archive-session scripts in throwaway repos with local bare remotes and a `gh` stand-in, following SKILL.md's New session, Resume and Close procedures; every commit and push went through the real guard.
- VER-014 (pending): the "Live" checks for DES-005, 006, 007 and 009 need the orchestrator model, real GitHub and a user answering prompts, and weren't run.

### 2026-10-24 — compass-labs:test — note: Branch guard stops applying once a session is archived
- Once Close sets `status: archived`, `list-sessions.sh` drops the session, so session-branch-guard.sh no longer blocks pushes to the default branch for it. REQ-009 is unaffected (it governs the orchestrator), but the no-merge rule has no mechanical enforcement after Close.

### 2026-10-24 — main — decision: Follow-up filed — #73 branch guard after archive
- The user chose to file the Test agent's note as a follow-up: once a session is archived the branch guard no longer covers it. Filed as #73 (parent #37); out of #37's scope.

### 2026-10-24 — main — decision: Test's integration script kept in tests/
- The user chose to keep the Test agent's 70-check integration script (real guard, session-start, default-branch, list-sessions and archive-session scripts in throwaway repos). Added as tests/integration/session_branch_integration_test.sh, with the plugin path taken from the file's location and its work dir under the harness's TMPDIR. bash tests/run.sh: 25 passed, 0 failed.

### 2026-10-24 — main — milestone: ✅ Test complete
- The user approved the Test gate with VER-014 pending. check-traceability.sh: ok. VER-001 to VER-013 pass; bash tests/run.sh 25/25 including the kept integration test.
- VER-014 (the live orchestrator checks for DES-005, 006, 007 and 009 against real GitHub) stays pending; verification.md frozen. Follow-up #73.

---

## Phase: Deploy

### 2026-10-24 — main — handoff: orchestrator → compass-labs:deploy (release #37)
- **Input:** Run the repo's deploy steps for #37 on feat/37-session-branch-on-open and record them in release.md, including the Completeness section. Merging PR #71 is the user's call and is out of Deploy's hands.
- **Output:** done; release.md

### 2026-10-24 — compass-labs:deploy — attempt: Release v2.2.0 prepared for #37; completeness has no gaps
- Release manifest checked as it ships (`marketplace.json`'s 16 skills, `hooks/hooks.json`'s 4 hooks): everything listed is complete and nothing complete is left out. The README hook table is missing `session-branch-guard.sh`; a row is proposed.
- `bash tests/run.sh` at `ba797ef`: 25 passed, 0 failed. `claude plugin tag --dry-run` stopped on the uncommitted `log.md`; re-run due after the bump.
- MINOR bump to v2.2.0 proposed (new hook and scripts, no skill interface change), with the default-branch block flagged for the user. Bump, README row, push and PR update listed for the orchestrator. Merge, tag `compass-labs--v2.2.0` and cache refresh are left to the user after the merge.

### 2026-10-24 — compass-labs:deploy — note: v2.1.0 tag name differs from the tool's convention
- v2.1.0 was tagged `v2.1.0`; `claude plugin tag` and the v2.0.0-and-earlier tags use `compass-labs--v{version}`. v2.2.0 will use `compass-labs--v2.2.0`. Rollback pins with `task lock PIN=v2.1.0`.

### 2026-10-24 — main — decision: README lists the session branch guard
- The user chose to add the missing `hooks/session-branch-guard.sh` row to README.md's "What the hooks enforce" table before the merge, as Deploy proposed.

### 2026-10-24 — main — decision: #37 ships as v2.2.0 (MINOR)
- The user chose MINOR: a new hook and scripts, no skill interface change. Blocking session commits and pushes on the default branch is the intended behaviour, not a break. .claude-plugin/plugin.json bumped 2.1.0 → 2.2.0.

### 2026-10-24 — main — milestone: ✅ Deploy complete
- The user approved the Deploy gate. release.md Completeness: everything listed is complete, nothing left out. bash tests/run.sh: 25/25 after the README row (966cc14) and the v2.2.0 bump (0ffbfef).
- PR #71 to be marked ready for review. Left to the user after merge (release.md steps 9–12): squash-merge #71, `claude plugin tag --push` (compass-labs--v2.2.0), `claude plugin update compass-labs@compass-labs`, restart and post-deploy checks.

---

## Phase: Close

### 2026-10-24 — main — note: Tag dry run passes; PR #71 ready for review
- `claude plugin tag --dry-run` after the Deploy commit: would create `compass-labs--v2.2.0` at HEAD; only the known non-blocking warnings (root CLAUDE.md, unquoted `$CLAUDE_PLUGIN_ROOT` in 4 hook commands).
- PR #71 retitled "feat: Session opens on a feature branch (v2.2.0) — #37" and marked ready for review. Not merged.

### 2026-10-24 — main — handoff: orchestrator → compass-labs:close (fold back #37)
- **Input:** Fold #37 back into the as-built docs (docs/reference, docs/explanation, docs/registry): default-branch.sh, list-sessions.sh, session-branch-guard.sh, the session-branch rules in the New session / Resume flows, the `branch:` log field, and the D1 PreToolUse-hook decision flagged as an ADR candidate. Follow-ups #70, #72, #73.
- **Output:** done; 11 files under docs/ (4 explanation/reference docs, patterns, registry index, decisions index, ADR-006, 3 construct docs)

### 2026-10-24 — main — note: PR #71 merged by the user during Close
- The user squash-merged PR #71 at 2026-10-24T07:27:59Z (d828edf on main), with head 6af38ba = the Deploy-complete commit, so everything through Deploy (code, tests, README row, v2.2.0 bump, verification.md, release.md) is on main.
- Close's fold-back and archive land after the merge, so they reach main through a second, docs-only PR.

### 2026-10-24 — compass-labs:close — note: Fold-back ready — #37 folded into the session docs, the registry and ADR-006
- Explanation: docs/explanation/session/overview.md covers the session branch (open, first push with the one-time draft PR prompt, Resume switch, Close leaving the merge to the user), the `branch` field, a "default branch only through a pull request" section with its component diagram, the `origin` dependency, and gotchas for #70, #72 and #73. docs/explanation/solution-design.md has a new key-decision bullet and an updated hooks line.
- Reference: docs/reference/session/hooks-and-scripts.md documents session-branch-guard.sh, the new session-start.sh output, default-branch.sh and list-sessions.sh; docs/reference/session/workflow-and-artifacts.md documents the `branch` key and a "Session branch and pull request" section with the no-merge rule.
- Decision: the PreToolUse-hook-on-Bash decision is ADR-006 (Accepted, refines ADR-002), indexed. Patterns: "Session work reaches the default branch only through a pull request", the guard added to "Hooks fail open", two anti-patterns.
- Constructs registered (built): SessionBranchGuard, DefaultBranchLookup, SessionLister (construct_count 2 → 5). Validate with `/compass-labs:post-hook-validator {name}`.
- One Origin line per touched doc; no session-local IDs; bash tests/run.sh 25/25. Not done: docs/index.html regeneration; the new diagram wasn't render-checked (no mermaid-cli).

### 2026-10-24 — main — decision: Follow-ups filed — #74 stale README and docs/index.html, #75 guard message names REQ-005
- From the Close report: README.md still says the branch and PR start at Implement, and docs/index.html wasn't regenerated (#74); session-branch-guard.sh's block message names the session-local "REQ-005" (#75). Both parent #37, out of Close's scope.

### 2026-10-24 — main — milestone: ✅ Session closed
- The user asked to close the session after merging PR #71 (d828edf, v2.2.0). Fold-back committed with this entry: 11 docs under docs/, including ADR-006 and three construct docs.
- PR #71 was merged before Close, so this commit and the archive move reach main on the next session's branch (#66, dark-mode diagram text), as the user asked. Follow-ups: #70, #72, #73, #74, #75.
