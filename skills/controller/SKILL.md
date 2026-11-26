---
name: controller
description: Runs your projects forward while you're away. On a schedule within your subscription's limits it picks the next ready issue (label trellis:ready), works it on a trellis/<n>-* branch with a problem brief alongside a pstack run, then runs close, opens the PR and logs the run. It follows the monthly cadence (weeks 1-3 the side projects, the last 7 days trellis itself). Modes are status, plan, run, install and uninstall. /trellis:controller [mode].
argument-hint: "[status | plan | run | install [--env-file F] | uninstall]"
---

# Controller

You set the vision and label what's ready. The controller does one task per slot and leaves a PR for you to review. Only you merge, and the merge guard enforces it.

Scripts run through `${CLAUDE_PLUGIN_ROOT}/skills/controller/scripts/`:

| Script | Does |
|---|---|
| `run.sh [--dry-run] [--force]` | One run: slot and daily-limit check, cadence, pick, brief ∥ pstack, close, log |
| `cadence.sh [YYYY-MM-DD]` | Prints `side` (weeks 1–3) or `compass` (last 7 days of the month) |
| `pick-task.sh <repo> <label>` | The oldest ready issue without an open `trellis/<n>-*` PR |
| `install-schedule.sh [--env-file F]` | One hourly crontab line. `run.sh` acts only in the configured local slots |
| `uninstall-schedule.sh` | Removes that line |

## Config

`~/.config/trellis/controller.json`, from [`templates/controller.json`](templates/controller.json):

| Key | Means |
|---|---|
| `timezone`, `slots` | Local times when a run may start, for example `["02:00"]`, while you sleep |
| `runs_per_day`, `max_minutes` | The usage budget: how many runs a day, and a hard stop for each pstack run |
| `model` | The session model for all three steps (default `sonnet`). pstack's roles come from `pstack-models.md` (`/trellis:setup`) |
| `label` | The issue label that means "ready for Claude" (default `trellis:ready`) |
| `projects` | `[{repo, role: "side"}]`: side projects, rotated by day |
| `compass_repo` | Where the trellis week works: trellis, picking up the month's `trellis` findings once you've turned them into labelled issues |
| `brief_repo`, `brief_day` | Where and on which day (`mon`…`sun`) the weekly brief is published. The first slot that day publishes it, with no model call |

Runs are logged to `~/.local/state/trellis/runs.jsonl`, with each run's transcripts under `runs/`. The weekly brief reads this log.

## Modes

- **status** (default): show the config, whether the schedule is installed (`crontab -l | grep trellis:controller`), the last 5 log lines as a table, and this week's cadence role.
- **plan:** `run.sh --dry-run`. Show what the next run would pick, and change nothing.
- **run:** ask once, then `run.sh --force`, which runs now regardless of the slot. It takes up to `max_minutes`.
- **install:** if the config is missing, write it with the user (repos, slot, time zone, budget), then `install-schedule.sh`. Suggest `--env-file` when the machine signs in with a stored token.
- **uninstall:** `uninstall-schedule.sh`.

## Safety

- Every claude call loads trellis, so the merge guard blocks `gh pr merge` and pushes to the default branch.
- pstack runs under [`reference/run-rule.md`](reference/run-rule.md): branch only, stop at verified, post nothing outside the branch and its PR.
- Tools are `acceptEdits` with Bash allowed, which the build and tests need. Point it only at repositories you trust it to run code in.
- A run that can't start cleanly logs `skipped` and touches nothing: a dirty working tree, no ready issue (`idle`), or the daily limit already reached.
