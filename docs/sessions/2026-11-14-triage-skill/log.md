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

- **2026-11-14**: Session branch `feat/86-triage-skill`, from `main`.

---

## Phase: Define

### 2026-11-14 — main — note: session opened
- Opened from the manual triage run of 2026-11-14 (47 → 37 open issues: 5 closed, 6 merged, 1 replacement opened as #85, 3 rewritten, every remaining issue commented). That run is the reference behaviour for this skill.
- Branch `feat/86-triage-skill` created from `main`.
