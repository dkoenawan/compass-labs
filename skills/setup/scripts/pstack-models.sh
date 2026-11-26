#!/usr/bin/env bash
# pstack-models.sh
# Checks and installs pstack's per-role model settings for a Claude
# subscription (ADR-011, #98). pstack reads them from
# ${CLAUDE_CONFIG_DIR:-~/.claude}/rules/pstack-models.md. Its own defaults
# name Fable (needs usage credits) and Gemini (another account), so Trellis
# installs a Claude-only file with nothing above `high` reasoning.
#
# Usage:
#   pstack-models.sh check [file]      exit 0 safe, 1 missing, 2 unsafe
#   pstack-models.sh install [--force] write the template (exit 3 if a
#                                      different file exists and no --force;
#                                      --force keeps a timestamped backup)
#   pstack-models.sh path              print the settings file path
#   pstack-models.sh conflicts         print other installed pstack plugins
#
# `check` prints one reason per line on stdout. Plain bash; jq only for
# `conflicts` (skipped without it).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/../templates/pstack-models.md"
CONFIG_DIR="${CLAUDE_CONFIG_DIR:-${HOME:-~}/.claude}"
TARGET="$CONFIG_DIR/rules/pstack-models.md"

# Roles pstack's setup-pstack writes (pstack 0.15.48, step 5).
ROLES=(
  "feature, refactoring"
  "bug-fix"
  "perf-issue"
  "hillclimb"
  "judgment and prose"
  "arena runners"
  "arena cross-judge pool"
  "swarm workers"
  "interrogate reviewers"
)

# check_file <file> : prints reasons, returns 0 safe / 1 missing / 2 unsafe
check_file() {
  local file="$1" reasons=() line value entry model effort role
  if [[ ! -f "$file" ]]; then
    echo "missing: $file"
    return 1
  fi
  [[ "$(head -n1 "$file")" != "---" ]] || reasons+=("starts with frontmatter; Claude Code's pstack adapter writes none")
  for role in "${ROLES[@]}"; do
    grep -q "^${role}: " "$file" || reasons+=("role missing: '$role' (pstack falls back to its default, which may need Fable or Gemini)")
  done
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" == \#* || "$line" != *": "* ]] && continue
    role="${line%%: *}"
    value="${line#*: }"
    IFS=',' read -r -a entries <<<"$value"
    for entry in "${entries[@]}"; do
      entry="$(echo "$entry" | xargs)"
      case "$entry" in inherit-parent|auto) continue ;; esac
      model="${entry%% *}"
      effort="${entry##* }"
      case "$model" in
        opus|sonnet|haiku) ;;
        *) reasons+=("role '$role' uses '$model': only opus, sonnet, haiku, inherit-parent or auto are safe on a subscription") ;;
      esac
      case "$effort" in
        low|medium|high) ;;
        *) reasons+=("role '$role' entry '$entry': effort above high, or none given") ;;
      esac
    done
  done <"$file"
  if [[ ${#reasons[@]} -gt 0 ]]; then
    printf 'unsafe: %s\n' "${reasons[@]}"
    return 2
  fi
  return 0
}

cmd="${1:-}"
case "$cmd" in
  check)
    check_file "${2:-$TARGET}"
    ;;
  install)
    mkdir -p "$(dirname "$TARGET")"
    if [[ -f "$TARGET" ]] && ! cmp -s "$TEMPLATE" "$TARGET"; then
      if [[ "${2:-}" != "--force" ]]; then
        echo "exists: $TARGET differs from the Trellis template; re-run with --force to replace it (a backup is kept)"
        exit 3
      fi
      backup="$TARGET.bak.$(date -u +%Y%m%dT%H%M%SZ)"
      cp "$TARGET" "$backup"
      echo "backup: $backup"
    fi
    cp "$TEMPLATE" "$TARGET"
    echo "installed: $TARGET"
    ;;
  path)
    echo "$TARGET"
    ;;
  conflicts)
    file="$CONFIG_DIR/plugins/installed_plugins.json"
    if [[ -f "$file" ]] && command -v jq >/dev/null 2>&1; then
      jq -r '.plugins // {} | keys[] | select(startswith("pstack@") and . != "pstack@cursor-plugins")' "$file" 2>/dev/null
    fi
    ;;
  *)
    echo "usage: pstack-models.sh check [file] | install [--force] | path | conflicts" >&2
    exit 64
    ;;
esac
