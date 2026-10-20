---
session: 2026-10-17-session-branch-on-open
type: feature
issue: 37
phase: implement
status: active
# milestone: the PHASE KEY of the last completed milestone, not a display
# label. Allowed values (feature workflow): none | define | design |
# implement | test | deploy | close. "none" until the first milestone
# (Define complete) is reached. The guard hook (D7) uses this key, plus
# each phase's `order` in workflows/<type>.json, to decide which
# artifacts are frozen. Display labels (e.g. "Define complete") live only
# in workflows/<type>.json's `milestone` field, for GitHub comments.
milestone: design
active_agent: compass-labs:implement
next_step: "Implement agent plans and builds DES-001 to DES-009 for #37"
---
# Session Log: Session opens on a feature branch (#37)

> Format: D2. Only the orchestrator writes this file. Entries are append-only.
> Artifacts: [`define/index.md`](define/index.md) · [`design/index.md`](design/index.md) · [`implement/`](implement/) · [`verification.md`](verification.md) · [`release.md`](release.md)

## Open items

- Follow-ups: #70 no remote / failed push; #72 Close closes the issue before the PR is merged.
- Work is on branch `feat/37-session-branch-on-open`; it reaches main through a PR.

## Key decisions

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
