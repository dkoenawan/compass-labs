#!/usr/bin/env bash
# archive-session.sh <session-dir>
# Moves a closed session folder into docs/sessions/archive/ (D6). Refuses
# to run unless:
#   - log.md's frontmatter status is exactly "archived" (the orchestrator
#     sets this — and commits it — before calling this script; log.md is
#     orchestrator-only, and once the folder is under archive/ the guard
#     hook blocks all further writes there, so the status flip must
#     happen and be committed BEFORE the move, not after).
#   - the working tree is clean (no uncommitted changes) — the move
#     itself should be its own clean commit, not bundled with unrelated
#     uncommitted edits.
#
# Exits 0 on a successful `git mv`. Exits 1 (with a reason on stderr) on
# any refusal. This script only moves the folder — it does not commit,
# push, touch log.md, or talk to GitHub; the orchestrator does all of
# that around it (see skills/session/SKILL.md's Close flow).

set -uo pipefail

session_dir="${1:?Usage: archive-session.sh <session-dir>}"
session_dir="${session_dir%/}"

if [[ ! -d "$session_dir" ]]; then
  echo "archive-session: session directory not found: $session_dir" >&2
  exit 1
fi

# Work with an absolute path from here on so `git -C "$repo_root" mv …`
# is correct regardless of the caller's own working directory.
session_dir="$(cd "$session_dir" && pwd)"

log_path="$session_dir/log.md"
if [[ ! -f "$log_path" ]]; then
  echo "archive-session: no log.md in $session_dir — refusing to archive a folder with no log" >&2
  exit 1
fi

case "$session_dir" in
  */archive/*|*/archive)
    echo "archive-session: $session_dir is already under archive/" >&2
    exit 1
    ;;
esac

repo_root="$(git -C "$session_dir" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$repo_root" ]]; then
  echo "archive-session: not inside a git repository" >&2
  exit 1
fi

frontmatter="$(awk '/^---$/{n++; next} n==1' "$log_path")"
status="$(echo "$frontmatter" | sed -n 's/^status:[[:space:]]*//p' | head -1)"

if [[ "$status" != "archived" ]]; then
  echo "archive-session: log.md status is '${status:-<missing>}', not 'archived'. Set status: archived, log the final milestone entry, and commit BEFORE archiving — see skills/session/SKILL.md's Close flow." >&2
  exit 1
fi

dirty="$(git -C "$repo_root" status --porcelain 2>/dev/null || true)"
if [[ -n "$dirty" ]]; then
  echo "archive-session: working tree is dirty — commit the status: archived change first, then archive as its own commit." >&2
  exit 1
fi

slug="$(basename "$session_dir")"
dest="$repo_root/docs/sessions/archive/$slug"

if [[ -e "$dest" ]]; then
  echo "archive-session: destination already exists: $dest" >&2
  exit 1
fi

mkdir -p "$repo_root/docs/sessions/archive"

if ! git -C "$repo_root" mv "$session_dir" "$dest"; then
  echo "archive-session: git mv failed" >&2
  exit 1
fi

echo "ok: archived $session_dir -> docs/sessions/archive/$slug"
exit 0
