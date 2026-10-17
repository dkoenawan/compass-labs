---
session: 2026-10-17-session-branch-on-open
type: feature
issue: 37
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
next_step: "Hand off to compass-labs:define to frame #37 and propose a tier"
---
# Session Log: Session opens on a feature branch (#37)

> Format: D2. Only the orchestrator writes this file. Entries are append-only.
> Artifacts: [`define/index.md`](define/index.md) · [`design/index.md`](design/index.md) · [`implement/`](implement/) · [`verification.md`](verification.md) · [`release.md`](release.md)

## Open items

- Work is on branch `feat/37-session-branch-on-open`; it reaches main through a PR.

## Key decisions

---

## Phase: Define

### 2026-10-17 — main — note: Session opened
- Issue #37 picked by the user. Branch `feat/37-session-branch-on-open` created from main (b1c2bcc) before the first commit, done by hand since this is the gap the session fixes.
