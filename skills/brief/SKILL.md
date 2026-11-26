---
name: brief
description: The weekly Compass brief, one short visual GitHub issue across all your projects. It shows the PRs waiting for you, the month's side-project vs compass-labs split against the 3:1 target (a pie), runs, failures and usage per project, and the month's findings, with the run log in a collapsed appendix. The controller publishes it on brief_day; /compass-labs:brief [preview | publish] runs it by hand.
argument-hint: "[preview | publish]"
---

# Weekly brief

One page a week, read in five minutes. It's built by scripts from the controller's run log, the projects' PRs and their `docs/findings/`, with no model call, so it costs no usage and says only what the data says.

| Script | Does |
|---|---|
| `bash ${CLAUDE_PLUGIN_ROOT}/skills/brief/scripts/gather.sh <dir> [date]` | Read-only snapshot: runs, `compass/*` PRs (open, merged this week), the month's findings |
| `bash ${CLAUDE_PLUGIN_ROOT}/skills/brief/scripts/render.sh <dir>` | Prints the brief's markdown |
| `bash ${CLAUDE_PLUGIN_ROOT}/skills/brief/scripts/publish.sh <brief.md> [date]` | Creates the `Compass brief {date}` issue in `brief_repo` and closes earlier ones. These are its only writes |

## Modes

- **preview** (default): gather into a temp directory, render, and show the markdown. Publish nothing.
- **publish:** preview, ask once, then publish and give the issue URL.

## What it measures

**Cadence:** the share of this month's completed runs that went to side projects, against the 75% target (weeks 1–3 side, the last week compass-labs). It's "on target" at 70% or more. `compass` findings are counted separately: they're the work list for the compass week.
