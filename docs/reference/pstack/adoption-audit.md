---
last_updated: 2026-11-26
---

# pstack adoption audit

> Origin: #98

What installing the official pstack adds to a machine, what it can do, and what Compass has to add around it. The decision is [ADR-011](../../registry/decisions/011-adopt-pstack-work-layer.md).

## Summary

| Check | Result |
|---|---|
| Source | `cursor/plugins` @ `b1fbf4b`, `pstack` 0.15.48, MIT, © Lauren Tan |
| Installed copy matches the audited source | ✅ Yes. `diff -r` shows only the cache's `.in_use` marker |
| Hooks | ✅ None |
| Scripts that run at install | ✅ None |
| Writes outside the project | 🟡 Only `~/.claude/rules/pstack-models.md`, when `setup-pstack` runs |
| Default models on a subscription | ❌ Unsafe: Fable (needs usage credits) and Gemini (another account). Fixed by [`pstack-models.md`](../../../skills/setup/templates/pstack-models.md) |
| Merging | ❌ The `shipping` and `autopilot-full` playbooks merge PRs. Compass needs a merge guard (follow-up) |
| External actions | 🟡 Its autonomy rule says team chat and ticket updates "proceed without asking" |

## Install

Installing compass-labs installs pstack as a plugin dependency (`"dependencies"` in `.claude-plugin/plugin.json`, with `cursor-plugins` allowlisted in `marketplace.json`). The user has to add pstack's marketplace first, because Claude Code never resolves a dependency from a marketplace the user hasn't added. Then `/compass-labs:setup` installs the model settings. See the README's Installation section.

Claude Code leaves auto-update off for third-party marketplaces. pstack has no release tags, so the dependency can't pin a version: it stays on whatever version the user installed until they update on purpose. Re-run this audit before recommending an update.

## What it installs

- **59 skill folders:** 35 skills and 24 `principle-*` references. All are Markdown except the scripts below.
- **2 agents:** `pstack:poteto-agent` (the worker) and `pstack:comment-sicko` (comment review).
- **No hooks.** Unlike the community port, nothing runs when a session starts.
- **Cursor names.** The skills keep Cursor's tool and model names. `docs/harness/claude-code.md` maps them, and Claude reads it during the session. If the mapping fails in a trial, that's a revisit condition in ADR-011.

### Bundled scripts

| Script | What it does | Risk |
|---|---|---|
| `poteto-mode/scripts/bootstrap.ts`, `watch-pr/` | Bun TypeScript. On first use it runs `bun install --frozen-lockfile` inside the plugin folder (network, locked versions), then watches a PR | Low. Needs Bun, which isn't on this VM, so PR watching is unavailable. Use `/steward` instead |
| `poteto-mode/scripts/worktree-audit.sh` | Lists git worktrees and their PRs. Only deletes its own temp file | Low |
| `show-me-your-work/scripts/log.sh` | Appends a row to a TSV decision log | Low |
| `statechart/scripts/` | TLA+ checking and Mermaid rendering (Bun, Java) | Not used |

## Behaviour to fence

| pstack behaviour | Where | Compass response |
|---|---|---|
| Default role models include `claude-fable-5-2-high` and `gemini-4-neon-xhigh`, and most roles run at `xhigh` | `setup-pstack` step 5 | Install [`pstack-models.md`](../../../skills/setup/templates/pstack-models.md): Claude only, `high` at most. `/compass-labs:setup` installs it and the session-start hook warns when it is missing or unsafe |
| `shipping` and `autopilot-full` run `gh pr merge` | `poteto-mode/playbooks/` | Unattended runs use `autopilot-stack` ("do not merge") or `autonomous-run`. A `PreToolUse` guard against `gh pr merge` and pushes to the default branch is a follow-up |
| "Just do it": external actions such as team chat and ticket updates proceed without asking | `poteto-mode` Autonomy | Unattended runs post nothing outside the repo's branch and PR. This goes in the Compass controller's run rule (follow-up) |
| `automate-me` reads recent session transcripts with parallel subagents | `automate-me` | Leave it out. It's usage-heavy and reads private history |
| `arena`, `swarm`, `interrogate` and `thermos`-style panels fan out to several models | panel roles | Leave out of unattended runs. Their roles are still set to Claude-only in case one is invoked |

## Skills we use (the "lite" list)

| Job | pstack skills |
|---|---|
| Entry and routing | `poteto-mode` and its playbooks: `bug-fix`, `feature`, `refactoring`, `autonomous-run`, `autopilot-stack`, `pause-safely`, `session-pickup` |
| Plan | `architect`, `in-your-own-words` |
| Build | `tdd` |
| Verify | `blast-radius`, `create-verification-skill` |
| Report | `show-me-your-work`, `ketchup`, `unslop` (prose clean-up for the brief) |
| Learn | `correct` |
| Principles | all 24 `principle-*`, especially `never-block-on-the-human`, which replaces Karpathy rule 1 in unattended runs |

The rest stay installed but aren't used in Compass runs.

## Smoke test

See [smoke-test-2026-11-26.md](smoke-test-2026-11-26.md).
