---
last_updated: 2026-11-26
---

# pstack smoke test, 2026-11-26

> Origin: #98

Two headless `poteto-mode` runs on a throwaway Python repo, after installing official pstack 0.15.48 and the subscription-safe [`pstack-models.md`](../../../skills/setup/templates/pstack-models.md). They check three things: pstack loads and routes in Claude Code, the role settings apply when it delegates, and an unattended run stays on its branch and reports honestly.

## Result

| | Run 1: bug fix | Run 2: feature with delegation |
|---|---|---|
| Task | Page 1 skips the first items (off-by-one) | Add `page_count`, validate `paginate` arguments |
| Outcome | ✅ Fixed on `fix/paginate`, regression tests added, all pass | ✅ Built on `feat/page-validation`, 7 new tests pass. One failure was already there (see note) |
| `main` untouched | ✅ | ✅ |
| Subagents | None (pstack's focused-fix exception) | 1 × `pstack:poteto-agent`, **`model: opus`, `effort: high`**, as the `feature` role line says |
| Models used | Sonnet 5.5 only | Sonnet 5.5 (main), Opus 5.5 (worker). **No Fable, no other vendor** |
| Wall time | 17 s | 71 s |
| Turns | 7 | 12 |
| Output tokens | 1.7k | 7.6k (3.6k Sonnet, 4.1k Opus) |
| API-equivalent cost¹ | $0.15 | $0.52 ($0.21 Sonnet, $0.32 Opus) |

¹ On a subscription nothing is billed. The figure is Claude Code's `total_cost_usd`, shown here only to compare runs. A subscription measures usage against its own limits.

**Note on run 2:** the one failing test is the off-by-one from run 1, which was fixed only on the other branch. The agent found it, said it was out of scope, didn't touch it, and recommended merging `fix/paginate` first. That's the honest reporting we want from unattended runs.

## How it was run

```bash
claude -p "/pstack:poteto-mode <task> … unattended run: don't stop to ask. Commit on a new branch …, never on main." \
  --model sonnet --permission-mode acceptEdits \
  --allowedTools "Read,Edit,Write,Glob,Grep,Agent,TodoWrite,Skill,Bash(python3:*),Bash(git:*),Bash(rg:*),Bash(ls:*),Bash(cat:*)" \
  --output-format stream-json --verbose
```

Evidence was taken from the `stream-json` output:
- the `init` event: `pstack@cursor-plugins` 0.15.48 loaded, with 59 `pstack:` commands
- each `Agent` tool call's `model` and `effort`
- the `result` event's `modelUsage`
- `git log --all` and `python3 -m unittest` in the repo afterwards

## Observations

- **Cursor names mapped correctly.** The run read pstack's `worker.md` and principle skills from the plugin cache. It spawned `pstack:poteto-agent`, the Claude Code name, and passed `model`/`effort` from the role line, so no Cursor slug reached the API.
- **It stayed within the run's limits.** It skipped "Opening a PR" because an unattended push is outward-facing.
- **Attribution.** The worker's commit carried a `Claude Opus 5.5` trailer, and the agent pointed this out itself.
- **Not tested here:** usage across a real multi-hour task, panel skills (`arena`, `interrogate`), and PR upkeep. Those are for the first real trial (#103).

## New-user install test

A clean `CLAUDE_CONFIG_DIR`, standing in for a user who has never installed anything, then the README's Installation steps:

| Step | Result |
|---|---|
| Install compass-labs **without** pstack's marketplace | Install "succeeds", but compass-labs is `✘ failed to load: Dependency "pstack@cursor-plugins" is not installed`. The README covers this case |
| `marketplace add cursor/plugins`, `marketplace add <compass-labs>`, `plugin install compass-labs@compass-labs` | ✅ `(+ 1 dependency: pstack)`. compass-labs 2.5.0 and pstack 0.15.48 both `✔ enabled` |
| Session start before setup | One line: `pstack's model settings aren't subscription-safe yet (missing: …). Tell the user to run /trellis:setup.` |
| `pstack-models.sh install`, the script `/trellis:setup` runs | ✅ `installed: <config>/rules/pstack-models.md`, `check` exit 0 |
| Session start after setup | ✅ Silent |
| Anything written outside the config dir | None (nothing under `~/.cursor/`) |
