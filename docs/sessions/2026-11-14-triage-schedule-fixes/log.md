---
session: 2026-11-14-triage-schedule-fixes
type: feature
issue: 93
# branch: the session branch, written once when the session opens, read by Resume.
branch: feat/93-triage-schedule-fixes
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
next_step: "Define: frame #93 and #91 and write requirements"
---
# Session Log: Triage scheduled-run fixes (#93)

> Format: D2. Only the orchestrator writes this file. Entries are append-only.
> Artifacts: [`define/index.md`](define/index.md) · [`design/index.md`](design/index.md) · [`implement/tasks.md`](implement/tasks.md) · [`verification.md`](verification.md) · [`release.md`](release.md)

## Open items

- #91 (report Run date uses the model's clock) is fixed in this session too and closed with it.

## Key decisions

- **2026-11-14**: User runs the session end to end to Close without stopping at each gate; merging the PR stays the user's call.
- **2026-11-14**: #93 and #91 handled in one session; #93 is the session issue, branch feat/93-triage-schedule-fixes.

---

## Phase: Define

### 2026-11-14 — main — decision: one session for #93 and #91
- User chose to fix #93 (install-schedule.sh resolves the claude symlink to a versioned binary) and #91 (report Run date from the model's clock) together. #93 is the session issue; #91 is recorded here and closed with it. Branch feat/93-triage-schedule-fixes accepted.

### 2026-11-14 — main — decision: run to Close
- User: "Run it till close." Gates are approved by the orchestrator unless something needs the user's input; the no-merge rule still applies.
