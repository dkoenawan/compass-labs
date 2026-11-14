---
session: 2026-11-14-triage-skill
type: feature
issue: 86
# branch: the session branch, written once when the session opens, read by Resume.
branch: feat/86-triage-skill
phase: define
status: active
# milestone: the PHASE KEY of the last completed milestone, not a display
# label. Allowed values (feature workflow): none | define | design |
# implement | test | deploy | close. "none" until the first milestone
# (Define complete) is reached. The guard hook (D7) uses this key, plus
# each phase's `order` in workflows/<type>.json, to decide which
# artifacts are frozen. Display labels (e.g. "Define complete") live only
# in workflows/<type>.json's `milestone` field, for GitHub comments.
milestone: none
active_agent: main
next_step: "Hand off to compass-labs:define to frame the problem and propose a tier"
---
# Session Log: Triage skill (#86)

> Format: D2. Only the orchestrator writes this file. Entries are append-only.
> Artifacts: [`define/index.md`](define/index.md) · [`design/index.md`](design/index.md) · [`implement/`](implement/) · [`verification.md`](verification.md) · [`release.md`](release.md)

## Open items

- The user wants the scheduled run on Saturdays at 01:00 Pacific/Auckland. The machine's cron runs in UTC; the existing mycelia job uses a TZ guard for this.
- The plugin rename (#34) is deferred by the user and is out of scope here, but the skill's name and commands will move with it.

## Key decisions

- **2026-11-14**: Anchor update agreed (extend Scope: "backlog triage" in Supporting skills).
- **2026-11-14**: REQ-027 (scheduled runs close covered-by-PR issues themselves) deferred to #88.
- **2026-11-14**: Framing answered by the orchestrator (delegated): full tier; scheduled run is propose-only (one report issue per run), actions only through an interactive, approved apply; local cron with a TZ guard, schedule as install parameters; grep-level checks unattended; duplicates, clusters and dependencies; anchor-less repos skip the mapping; anchor Scope gains "backlog triage".
- **2026-11-14**: User delegated every gate to the orchestrator through to Close ("Continue all the way until close. I'll review and come back after."). Orchestrator answers phase questions and approves milestones, logging each answer as a decision; no merge.
- **2026-11-14**: Session branch `feat/86-triage-skill`, from `main`.

---

## Phase: Define

### 2026-11-14 — main — note: session opened
- Opened from the manual triage run of 2026-11-14 (47 → 37 open issues: 5 closed, 6 merged, 1 replacement opened as #85, 3 rewritten, every remaining issue commented). That run is the reference behaviour for this skill.
- Branch `feat/86-triage-skill` created from `main`.

### 2026-11-14 — main — note: draft pull request opened
- https://github.com/dkoenawan/compass-labs/pull/87 (draft, `feat/86-triage-skill` → `main`).

### 2026-11-14 — main — handoff: orchestrator → compass-labs:define (frame problem, propose tier)
- **Input:** frame the problem for #86 and propose a depth tier. Reference behaviour is the 2026-11-14 manual triage. The user wants it on a schedule: Saturdays 01:00 Pacific/Auckland.
- **Output:** needs_input; files_changed: none (tier, need, authority, report, modes, scheduler, checking depth, mapping, anchor-less repos, anchor wording)

### 2026-11-14 — main — decision: gates delegated to the orchestrator until Close
- The user said: "Continue all the way until close. I'll review and come back after."
- So the orchestrator answers phase agents' questions and approves each milestone itself, recording every answer as a `decision` entry for the user to review afterwards. The no-merge rule still holds: the PR stays open for the user.

### 2026-11-14 — compass-labs:define — note: framing started, tier proposed
- Proposed tier: full (a new skill plus an unattended scheduler writing to GitHub; touches the anchor scope and the "no replacing user approval" non-goal).
- Anchor complete (README.md lines 11-44); draft verdict extends (Scope "Supporting skills" line has no triage). Registry/ADR: no overlapping construct; pattern overlap with the doc-maintainer and task-executor install-schedule scripts; ADR-006 applies only if the run commits.
- Waiting on the user: tier, the need (XY), unattended authority, report location and approval route, modes, scheduler mechanism, checking depth, cross-issue mapping, anchor-less repos, anchor wording.

### 2026-11-14 — main — decision: framing questions answered (delegated)
- Answered by the orchestrator under the user's delegation; chose the conservative, reversible option where the user hadn't said. For the user to review.
- **Q1 tier:** full, as proposed.
- **Q2 need:** the need is a backlog that stays aligned with the anchor and merged work without anyone remembering to triage. The weekly schedule is also a stated requirement for this repo (Saturdays 01:00 Pacific/Auckland).
- **Q3 authority:** (a) for the scheduled run. Its only GitHub writes are creating its own report issue and closing its own previous, unapplied report as superseded. Closing, duplicate-marking, body edits, new issues and triage comments happen only in an interactive apply the user approves, as in the reference run. Why: the anchor's non-goal "Replacing user approval at milestones", and the user wasn't present to choose. Loosening this (e.g. option (c), unattended low-risk closes) is a follow-up for the user to decide.
- **Q4 report:** one GitHub issue per run ("Triage YYYY-MM-DD", labelled `triage`) holding the whole stock-take and proposed actions. Approval is the user running the skill interactively to apply a named report, confirming per group; GitHub replies are not approval.
- **Q5 modes:** both: interactive (stock-take, then apply on approval, as on 2026-11-14) and scheduled (propose only).
- **Q6 scheduler:** local cron through install-schedule.sh / uninstall-schedule.sh, like the existing skills, with a TZ guard so the local time holds across DST. Day, time and time zone are install parameters; this user's setting is Saturday 01:00 Pacific/Auckland. No cloud routine (it wouldn't have the local checkout).
- **Q7 checking depth:** unattended: grep the code and read merged PRs, no test runs. Interactive mode may also run tests on a scratch copy.
- **Q8 cross-issue mapping:** duplicates and clusters, plus dependencies (blocked-by, as #69 blocks the layer issues). No priority: prioritising is the user's call.
- **Q9 no anchor:** skip the anchor mapping, say so in the report and recommend creating one; don't stop.
- **Q10 anchor wording:** approved as drafted: "- Supporting skills: scaffolding, planning, codebase exploration, documentation, architecture decisions, task execution, backlog triage, brand design." With Q3 (a), no non-goal change is needed.

### 2026-11-14 — compass-labs:define — decision: anchor update (extend Scope)
- Action `extend`, element Scope. Replace the Supporting skills line with: "- Supporting skills: scaffolding, planning, codebase exploration, documentation, architecture decisions, task execution, backlog triage, brand design."
- Relayed as approved by the orchestrator under the user's stated delegation (framing answer Q10). The user reviews it in PR #87 before merge.
- Verdict extends, resting on Scope "Supporting skills: …" and the non-goal "Replacing user approval at milestones", which scheduled runs stay inside by only proposing.

### 2026-11-14 — compass-labs:define — attempt: define/ written to full tier
- Tier full, from framing answers Q1 to Q10 relayed by the orchestrator. Needs NEED-01 to NEED-04, outcomes OUT-01 to OUT-05.
- Requirements REQ-001 to REQ-025 and REQ-028 live. REQ-026 (proposing priorities) struck as never. REQ-027 (a scheduled run closing covered-by-merged-PR issues itself) deferred.

### 2026-11-14 — main — decision: REQ-027 deferred to #88; remaining Define questions answered (delegated)
- Opened #88 for REQ-027: scheduled runs closing issues covered by a merged PR without an apply. Needs the user's own decision.
- `triage` label: created by the interactive installer and by an interactive apply when missing. A scheduled run never creates labels; it publishes without the label and says so.
- An interactive stock-take publishes no report issue by default; it applies directly on confirmation.
- Appetite: one session, about two days for Implement.
