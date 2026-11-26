# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a **Claude Code plugin repository** that runs software development, research and consulting work as sessions, based on common established enterprise frameworks. Its vision, mission and scope are the `## Project anchor` section of `README.md`. It follows the Claude Code plugin architecture as documented at https://code.claude.com/docs/en/plugins.

## Architecture

### Plugin Structure

This repository follows the standard Claude Code plugin structure:

- `.claude-plugin/plugin.json` - Plugin manifest (required, contains metadata only)
- `skills/` - One folder per skill: `setup`, `controller`, `problem-statement`, `close`, `brief`, `deploy`, `triage`, `adr`, `init` (ADR-012). The work itself is done by the pstack dependency (ADR-011)
- No `agents/` today. If one is added, its `name` frontmatter never contains `:` (plugin-scoped invocation is derived automatically)
- `commands/` - Direct command skills that don't require AI model invocation
- `hooks/` - `merge-guard.sh` (only the user merges) and `session-start.sh` (pstack settings check)
- `tests/` - Bash + jq test harness (`tests/run.sh`) for hooks and scripts; not part of the plugin's runtime surface, but tracked in the repo like everything else
- Root-level directories only (never nest `skills/`, `commands/`, `hooks/`, `agents/` inside `.claude-plugin/`)

### Skill Organization

Skills are small and brief-first: a short summary for the reader, with detail one click away (drill-down). Prefer adopting a proven tool over building a skill (ADR-011). Retired skills and their docs are in `docs/archive/`, and archived ADRs are listed in `docs/registry/decisions/index.md`.

Each skill is namespaced as `/compass-labs:skill-name` when invoked.

## Key Constraints

### Directory Structure Rules

**CRITICAL**: Only `plugin.json` goes inside `.claude-plugin/`. All other directories (`skills/`, `commands/`, `hooks/`) must be at the plugin root level.

### Skill Definition Format

Each skill requires a `SKILL.md` file with frontmatter:

```markdown
---
name: skill-name
description: What the skill does
---

Skill instructions here...
```

### Plugin Manifest

The `plugin.json` must contain at minimum:
- `name`: "compass-labs"
- `description`: Plugin description
- `version`: Semantic version (e.g., "1.0.0")
- `author`: Author information

## Development Workflow

### Testing the Plugin Locally

```bash
claude --plugin-dir /home/su-sentinel/private/compass-labs
```

### Adding New Skills

1. Create directory under `skills/` (e.g., `skills/new-skill/`)
2. Add `SKILL.md` with proper frontmatter
3. Test with `claude --plugin-dir .`
4. Update README.md to document the new skill

### Version Management

Follow semantic versioning in `plugin.json`:
- MAJOR: Breaking changes to skill interfaces
- MINOR: New skills or backward-compatible enhancements
- PATCH: Bug fixes and documentation updates

## Important Notes

- This plugin is designed for **public distribution** and reuse across projects
- Skills should be **opinionated** and provide clear, systematic guidance
- Each skill should follow **established best practices** for its domain
- Skills are intended to work **independently** but can reference each other
- Keep skills **focused** - one clear purpose per skill
