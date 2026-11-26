---
date: 2026-11-26
type: risk
title: Renamed runtime names need a manual step on live installs
pr: #106
issue: #34
---

# Renamed runtime names need a manual step on live installs

| Old | New |
|---|---|
| label `compass:ready` | `trellis:ready` (not yet created on GitHub) |
| `~/.config/compass`, `~/.local/state/compass` | `~/.config/trellis`, `~/.local/state/trellis` |
| `COMPASS_*` env vars | `TRELLIS_*` |
| installed triage cron | must be reinstalled |

- Open issues labelled `compass:ready` will not be picked up after merge.
- The maintainer must create the label, move the config dirs and reinstall the schedule.
- Nothing yet: README has an upgrade note, but nothing automates the move.

Evidence: docs/briefs/2026-11-26-rename-the-plugin-to-trellis.md (⚠ assumption) · PR #106
