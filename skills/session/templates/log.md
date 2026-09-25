---
session: {date}-{slug}
type: feature
issue: {github-issue-number}
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
active_agent: {agent name or "main"}
next_step: "{what happens next}"
---
# Session Log: {Session Title} (#{issue})

> Format: D2. Only the orchestrator writes this file. Entries are append-only.
> Artifacts: [`requirements.md`](requirements.md) · [`design.md`](design.md) · [`tasks.md`](tasks.md) · [`verification.md`](verification.md) · [`release.md`](release.md)

## Open items

- {something unresolved that the next pickup needs to know about}

## Key decisions

- **{date}**: {decision, newest first}

---

## Phase: Define

### {date} — {actor} — {event type}: {title}
- {what happened, why, and any handoff}
