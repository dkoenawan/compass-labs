---
name: setup
description: One-time setup after installing compass-labs. Installs pstack's subscription-safe model settings (Claude models only, nothing above high reasoning) at ~/.claude/rules/pstack-models.md, checks them, and flags a second pstack plugin. Use for /compass-labs:setup, after the session-start warning about pstack's model settings, or after running pstack's own /pstack:setup-pstack.
---

# Setup

compass-labs uses the official pstack (`pstack@cursor-plugins`) as its work layer (ADR-011). Installing compass-labs installs pstack as a dependency, but not pstack's model settings. pstack's defaults name Fable, which needs usage credits, and Gemini, which needs another account. On a Claude subscription those roles fail or cost extra. This skill installs Compass's safe settings.

All mechanics go through one script. Run it through `${CLAUDE_PLUGIN_ROOT}`, never by a path relative to the working directory:

| Command | Does |
|---|---|
| `bash ${CLAUDE_PLUGIN_ROOT}/skills/setup/scripts/pstack-models.sh check` | Exit 0 safe, 1 missing, 2 unsafe, with one reason per line |
| `bash ${CLAUDE_PLUGIN_ROOT}/skills/setup/scripts/pstack-models.sh install [--force]` | Writes the template. Without `--force` it refuses (exit 3) to replace a different file; with `--force` it keeps a timestamped backup |
| `bash ${CLAUDE_PLUGIN_ROOT}/skills/setup/scripts/pstack-models.sh conflicts` | Lists other installed pstack plugins, such as the community port `pstack@pstack-claude` |

## Steps

1. Run `check` and `conflicts`.
2. **Settings missing (exit 1):** run `install`, then say the file was written and that it applies to new sessions.
3. **Settings unsafe (exit 2):** show the reasons, which usually mean someone ran `/pstack:setup-pstack` in Claude Code. Ask once whether to replace them. A backup is kept. On yes, run `install --force`. On no, stop and say which roles will fail on a subscription.
4. **Settings safe (exit 0):** say so in one line and change nothing.
5. **Another pstack plugin listed:** recommend uninstalling it (`claude plugin uninstall <name>`), because both register `/pstack:` commands. Don't uninstall it yourself.
6. End with the role table from the template, one line per role, so the user sees which model each role runs.

## Cursor

This only writes Claude Code's file, `~/.claude/rules/pstack-models.md`. pstack in Cursor uses `~/.cursor/rules/pstack-models.mdc` and keeps its own settings. Never write or change anything under `~/.cursor/`.
