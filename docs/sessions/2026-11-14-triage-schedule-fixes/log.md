---
session: 2026-11-14-triage-schedule-fixes
type: feature
issue: 93
# branch: the session branch, written once when the session opens, read by Resume.
branch: feat/93-triage-schedule-fixes
phase: design
status: active
# milestone: the PHASE KEY of the last completed milestone, not a display
# label. Allowed values (feature workflow): none | define | design |
# implement | test | deploy | close. "none" until the first milestone
# (Define complete) is reached. The guard hook (D7) uses this key, plus
# each phase's `order` in workflows/<type>.json, to decide which
# artifacts are frozen. Display labels (e.g. "Define complete") live only
# in workflows/<type>.json's `milestone` field, for GitHub comments.
milestone: define
active_agent: main
next_step: "Design: classify and write design/ for REQ-001–REQ-006"
---
# Session Log: Triage scheduled-run fixes (#93)

> Format: D2. Only the orchestrator writes this file. Entries are append-only.
> Artifacts: [`define/index.md`](define/index.md) · [`design/index.md`](design/index.md) · [`implement/tasks.md`](implement/tasks.md) · [`verification.md`](verification.md) · [`release.md`](release.md)

## Open items

- #91 (report Run date uses the model's clock) is fixed in this session too and closed with it.

## Key decisions

- **2026-11-14**: ✅ Define complete — short tier, REQ-001–REQ-006 frozen.
- **2026-11-14**: REQ-001–REQ-006 agreed: unresolved absolute binary paths (claude and gh), survive version removal, local run date into the prompt and enforced in the published header, docs updated with reinstall guidance.
- **2026-11-14**: Define framed at short tier; anchor verdict aligns, no anchor update.
- **2026-11-14**: User runs the session end to end to Close without stopping at each gate; merging the PR stays the user's call.
- **2026-11-14**: #93 and #91 handled in one session; #93 is the session issue, branch feat/93-triage-schedule-fixes.

---

## Phase: Define

### 2026-11-14 — main — decision: one session for #93 and #91
- User chose to fix #93 (install-schedule.sh resolves the claude symlink to a versioned binary) and #91 (report Run date from the model's clock) together. #93 is the session issue; #91 is recorded here and closed with it. Branch feat/93-triage-schedule-fixes accepted.

### 2026-11-14 — main — decision: run to Close
- User: "Run it till close." Gates are approved by the orchestrator unless something needs the user's input; the no-merge rule still applies.

### 2026-11-14 — main — note: draft PR opened
- https://github.com/dkoenawan/compass-labs/pull/94

### 2026-11-14 — main — handoff: orchestrator → compass-labs:define (frame #93 + #91)
- **Input:** frame and write requirements for #93 (install-schedule.sh resolve_bin runs realpath, pinning a versioned claude binary that auto-update removes) and #91 (run-scheduled.sh doesn't pass the local run date into the headless prompt, so the report header's Run date can be the UTC day). User wants the session run to Close without stopping; pick sensible defaults rather than asking where possible.
- **Output:** done; define/index.md, define/framing.md, define/problem.md, define/requirements.md

### 2026-11-14 — compass-labs:define — decision: Define framed at short tier
- Tier: short. Two contained bugs in `install-schedule.sh` and `run-scheduled.sh` with known causes, but both break the unattended run's promise of a correctly dated weekly report. Proposed by the Define agent and taken as the default under the user's "run it till close" instruction.
- XY: both issues' fixes moved to Candidate solutions. Needs are NEED-01 (runs survive claude/gh self-updates) and NEED-02 (header date matches title).
- Anchor complete, verdict aligns (Scope: "Supporting skills: … backlog triage …"). Anchor update: none. Overlaps/conflicts: none found (TriageSchedule, TriageScheduledRun and ADR-010 checked).

### 2026-11-14 — compass-labs:define — decision: requirements REQ-001 to REQ-006 agreed
- REQ-001 to REQ-003 (Must, OUT-01): cron lines keep absolute, unresolved binary paths (found on PATH or overridden), and a run survives the removal of the version present at install.
- REQ-004 (Must, OUT-02): the local run date is given to the headless model. REQ-005 (Should, OUT-02): the published header's Run date is the local run date. REQ-006 (Should): the docs drop the #91/#93 limitations and give reinstall guidance.
- Defaults taken without asking: covers gh as well as claude; deterministic date backstop (REQ-005); no automatic crontab migration. Deferred: none.

### 2026-11-14 — compass-labs:define — note: Define artifact ready for the gate
- `gh issue view` couldn't be run (no shell available to the agent). Issue evidence comes from the handoff, the code and the triage docs that already describe #91 and #93.

### 2026-11-14 — main — milestone: ✅ Define complete
- Approved by the orchestrator under the user's "run it till close" instruction. Short tier, REQ-001–REQ-006 frozen.

---

## Phase: Design
