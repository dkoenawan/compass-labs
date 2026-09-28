#!/usr/bin/env bash
# session-guard.sh
# PreToolUse hook for Write|Edit|MultiEdit. Enforces D7 inside
# docs/sessions/{id}/: the D1 file allowlist, artifact ownership by
# agent_type, frozen artifacts, and a read-only archive/. Everything
# outside docs/sessions/ is untouched.
#
# Folder artifacts (#23 DES-020, D13): a phase whose `artifact` ends in
# `/` (e.g. define/) owns that folder as a unit. Only the files in its
# fixed `artifact_files` set, one level deep, may be written; ownership
# and freezing resolve by the folder prefix. A phase's `legacy_artifact`
# (the root requirements.md past sessions use) stays writable only in a
# session that already has it, and such a session can't start the folder:
# one layout per session, and nothing is migrated (D6).
#
# Reads the PreToolUse hook JSON from stdin. Exit 2 (with a reason on
# stderr) blocks the write; exit 0 allows it. Fails OPEN (exit 0, warning
# on stderr) if jq is missing or the workflow file can't be read, since
# this plugin is publicly distributed and must not hard-block a repo that
# hasn't got everything wired up yet.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/session-log.sh
source "$SCRIPT_DIR/lib/session-log.sh"

input="$(cat)"

# --- jq must be available; fail open otherwise. ------------------------
if ! command -v jq >/dev/null 2>&1; then
  echo "[session-guard] WARNING: jq not found — allowing write (fail open)" >&2
  exit 0
fi

tool_name=$(jq -r '.tool_name // empty' <<<"$input")
file_path=$(jq -r '.tool_input.file_path // empty' <<<"$input")
cwd=$(jq -r '.cwd // empty' <<<"$input")
agent_id=$(jq -r '.agent_id // empty' <<<"$input")
agent_type=$(jq -r '.agent_type // empty' <<<"$input")

case "$tool_name" in
  Write|Edit|MultiEdit) ;;
  *) exit 0 ;;
esac

[[ -n "$file_path" ]] || exit 0
[[ -n "$cwd" ]] || cwd="$(pwd)"

# normalize_path <path>
# Lexically collapses '.' and '..' segments in an absolute path — pure
# string manipulation, no filesystem access. A `cd`-based normalization
# (the previous approach) silently fails whenever a directory in the path
# doesn't exist yet, which is the common case for a Write to a brand-new
# file: `..` segments then survive uncollapsed and can walk the check
# right out of docs/sessions/{id}/ (e.g. `assets/../notes.txt` looking
# like it's under assets/). This must not depend on the file/dir existing.
normalize_path() {
  local input="$1"
  local IFS='/'
  local -a segments
  read -r -a segments <<<"$input"
  local -a parts=()
  local seg
  for seg in "${segments[@]}"; do
    case "$seg" in
      ""|".") continue ;;
      "..")
        [[ ${#parts[@]} -gt 0 ]] && unset 'parts[${#parts[@]}-1]'
        ;;
      *)
        parts+=("$seg")
        ;;
    esac
  done
  if [[ ${#parts[@]} -eq 0 ]]; then
    printf '/\n'
  else
    printf '/%s\n' "${parts[*]}"
  fi
}

# --- Resolve the repo root. --------------------------------------------
repo_root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "$repo_root" ]] || repo_root="$cwd"

# cwd must exist as a directory (it's where the tool is running from), so
# resolving it physically (symlinks included) is safe and keeps it
# consistent with repo_root, which `git rev-parse --show-toplevel` also
# returns as a physically-resolved path. The FILE itself usually doesn't
# exist yet, so its path is normalized lexically only (normalize_path
# above), not resolved against the filesystem. This is a deliberate
# simplification: a symlink *inside* the session-relative tail of the
# path (rather than in cwd) is not resolved — session folders aren't
# expected to contain symlinks, so this is not treated as a gap.
cwd_physical="$(cd "$cwd" 2>/dev/null && pwd -P)"
[[ -n "$cwd_physical" ]] || cwd_physical="$cwd"

# --- Resolve file_path to an absolute path, then make it repo-relative. -
if [[ "$file_path" == /* ]]; then
  abs_path="$file_path"
else
  abs_path="$cwd_physical/$file_path"
fi

abs_path="$(normalize_path "$abs_path")"

case "$abs_path" in
  "$repo_root"/*) rel="${abs_path#"$repo_root"/}" ;;
  *) exit 0 ;; # outside the repo entirely — not our business
esac

# --- Only act inside docs/sessions/. ------------------------------------
case "$rel" in
  docs/sessions/*) ;;
  *) exit 0 ;;
esac

after_sessions="${rel#docs/sessions/}"

# --- Archive is always read-only. ---------------------------------------
case "$after_sessions" in
  archive/*)
    echo "[session-guard] BLOCKED: docs/sessions/archive/ is frozen — archived sessions are read-only." >&2
    exit 2
    ;;
esac

session_id="${after_sessions%%/*}"
path_in_session="${after_sessions#"$session_id"/}"

# A write directly to docs/sessions/<id> with no file component — nothing
# to enforce a set against; let it fall through to normal tool behavior.
if [[ "$path_in_session" == "$after_sessions" || -z "$path_in_session" ]]; then
  exit 0
fi

session_dir="$repo_root/docs/sessions/$session_id"
log_path="$session_dir/log.md"

# --- Brand-new session: only log.md may be created first. ---------------
# Exception: the `plan` skill keeps its spec at docs/sessions/<id>/overview.md
# with no log.md. A folder without log.md isn't a lifecycle session, so the
# plan spec is allowed there (and only that file).
if [[ ! -f "$log_path" ]]; then
  if [[ "$path_in_session" == "log.md" || "$path_in_session" == "overview.md" ]]; then
    exit 0
  fi
  echo "[session-guard] BLOCKED: session '$session_id' has no log.md yet. The orchestrator creates log.md first; nothing else may be written before it exists." >&2
  exit 2
fi

# --- assets/: anything but Markdown. -------------------------------------
if [[ "$path_in_session" == assets/* ]]; then
  if [[ "$path_in_session" == *.md ]]; then
    echo "[session-guard] BLOCKED: Markdown is not allowed under assets/ ($path_in_session). assets/ holds non-Markdown artifacts only (D1)." >&2
    exit 2
  fi
  exit 0
fi

# --- Depth: nothing more than one folder deep. ---------------------------
# Folder artifacts (e.g. define/, #23 DES-020) are one level deep, so a
# path with two or more slashes inside the session is never valid.
unknown_subdir() {
  echo "[session-guard] BLOCKED: unknown subdirectory in session folder ($path_in_session). Only the top-level artifact set, declared folder artifacts and assets/ are allowed (D1)." >&2
  exit 2
}
if [[ "$path_in_session" == */*/* ]]; then
  unknown_subdir
fi

# --- Read session type + milestone from log.md frontmatter. -------------
frontmatter="$(awk '/^---$/{n++; next} n==1' "$log_path")"
session_type="$(echo "$frontmatter" | sed -n 's/^type:[[:space:]]*//p' | head -1)"
[[ -n "$session_type" ]] || session_type="feature"
milestone_key="$(echo "$frontmatter" | sed -n 's/^milestone:[[:space:]]*//p' | head -1)"
[[ -n "$milestone_key" ]] || milestone_key="none"

# --- Load the workflow definition for this session type. ----------------
# Fails open for a top-level path, but a path with a / is still blocked as
# an unknown subdirectory: without the workflow there's no way to know a
# folder artifact is declared, and that was the behaviour before folders.
plugin_root="${CLAUDE_PLUGIN_ROOT:-$repo_root}"
workflow_file="$plugin_root/skills/session/workflows/${session_type}.json"

if [[ ! -f "$workflow_file" ]] || ! jq empty "$workflow_file" >/dev/null 2>&1; then
  if [[ "$path_in_session" == */* ]]; then
    unknown_subdir
  fi
  echo "[session-guard] WARNING: workflow file unreadable ($workflow_file) — allowing write (fail open)" >&2
  exit 0
fi

# --- log.md: orchestrator (main session) only. ---------------------------
if [[ "$path_in_session" == "log.md" ]]; then
  if [[ -n "$agent_id" ]]; then
    echo "[session-guard] BLOCKED: log.md is written only by the orchestrator (main session), never by a subagent (D4)." >&2
    exit 2
  fi
  exit 0
fi

# --- Resolve the artifact key. -------------------------------------------
# A top-level file must match the allowlist exactly; its key is its name.
# A `dir/file` path must be inside an allowlisted folder that some phase
# declares as its `artifact`, and `file` must be in that phase's fixed
# `artifact_files`; its key is `dir/`, so every file in the folder shares
# one owner and one freeze point (a prefix match on the folder, D13).
allowlist="$(jq -r '.session_level.file_allowlist[]' "$workflow_file")"
if [[ "$path_in_session" == */* ]]; then
  folder="${path_in_session%%/*}/"
  file_in_folder="${path_in_session#*/}"
  folder_phase="$(jq -r --arg a "$folder" '.phases[] | select(.artifact == $a) | .phase' "$workflow_file")"
  if ! grep -qxF "$folder" <<<"$allowlist" || [[ -z "$folder_phase" ]]; then
    unknown_subdir
  fi
  folder_files="$(jq -r --arg a "$folder" '.phases[] | select(.artifact == $a) | .artifact_files[]?' "$workflow_file")"
  if [[ -z "$file_in_folder" ]] || ! grep -qxF "$file_in_folder" <<<"$folder_files"; then
    echo "[session-guard] BLOCKED: '$path_in_session' is not one of ${folder}'s files ($(echo $folder_files | tr ' ' ',' | sed 's/,/, /g')) (D13)." >&2
    exit 2
  fi
  artifact_key="$folder"
else
  if ! grep -qxF "$path_in_session" <<<"$allowlist"; then
    echo "[session-guard] BLOCKED: '$path_in_session' is not in this workflow's session file set (D1/D7)." >&2
    exit 2
  fi
  artifact_key="$path_in_session"
fi

# --- Ownership: which phase owns this artifact? --------------------------
# A past session's root file (a phase's `legacy_artifact`) belongs to the
# same phase as its folder artifact.
owner_select='.phases[] | select(.artifact == $k or .legacy_artifact == $k)'
owner_agent="$(jq -r --arg k "$artifact_key" "$owner_select | .owner_agent" "$workflow_file")"
artifact_order="$(jq -r --arg k "$artifact_key" "$owner_select | .order" "$workflow_file")"

if [[ -z "$owner_agent" || -z "$artifact_order" ]]; then
  echo "[session-guard] BLOCKED: no phase in $workflow_file owns artifact '$artifact_key' — refusing to guess." >&2
  exit 2
fi

# --- One layout per session (D6). ----------------------------------------
# A new session writes the folder; a past session that's still open keeps
# its root file. Nothing converts one layout into the other.
legacy_for_key="$(jq -r --arg k "$artifact_key" '.phases[] | select(.legacy_artifact == $k) | .legacy_artifact' "$workflow_file")"
if [[ -n "$legacy_for_key" && ! -f "$session_dir/$legacy_for_key" ]]; then
  new_layout="$(jq -r --arg k "$artifact_key" '.phases[] | select(.legacy_artifact == $k) | .artifact' "$workflow_file")"
  echo "[session-guard] BLOCKED: '$path_in_session' is the root layout past sessions use; new sessions write $new_layout instead (D6/D13)." >&2
  exit 2
fi
if [[ "$artifact_key" == */ ]]; then
  folder_legacy="$(jq -r --arg k "$artifact_key" '.phases[] | select(.artifact == $k) | .legacy_artifact // empty' "$workflow_file")"
  if [[ -n "$folder_legacy" && -f "$session_dir/$folder_legacy" ]]; then
    echo "[session-guard] BLOCKED: '$path_in_session' — this session uses the root layout ($folder_legacy exists), so it can't also use $artifact_key (D6: one layout per session)." >&2
    exit 2
  fi
fi

if [[ -n "$agent_id" ]]; then
  # Subagent: must be the exact owner of this artifact.
  if [[ "$agent_type" != "$owner_agent" ]]; then
    echo "[session-guard] BLOCKED: '$path_in_session' is owned by $owner_agent; agent_type '$agent_type' may not write it (REQ-005)." >&2
    exit 2
  fi
fi
# Main session (no agent_id) may write any allowlisted artifact.

# --- Frozen check: phases at or before the last completed milestone. ----
milestone_order="0"
if [[ "$milestone_key" != "none" ]]; then
  milestone_order="$(jq -r --arg p "$milestone_key" '.phases[] | select(.phase == $p) | .order' "$workflow_file")"
  [[ -n "$milestone_order" && "$milestone_order" != "null" ]] || milestone_order="0"
fi

is_frozen=false
if [[ "$artifact_order" -le "$milestone_order" ]]; then
  is_frozen=true
fi

if [[ "$is_frozen" == true ]]; then
  if [[ -n "$agent_id" ]]; then
    echo "[session-guard] BLOCKED: '$path_in_session' is frozen (milestone: $milestone_key). Subagents may never amend a frozen artifact — only the orchestrator can, and only with a logged decision (D7/D8)." >&2
    exit 2
  fi

  # Main session may amend a frozen artifact only with an uncommitted,
  # newly-added `decision` entry in log.md (a `git diff` add-line with a
  # "— decision:" heading), or if log.md itself is untracked. Shared with
  # session-commit-guard.sh's Stop check — see hooks/lib/session-log.sh.
  if ! session_log_has_uncommitted_heading "$repo_root" "$log_path" '— decision:'; then
    echo "[session-guard] BLOCKED: '$path_in_session' is frozen (milestone: $milestone_key). Log a decision entry in log.md first, then amend the artifact in the same commit (D7/D8)." >&2
    exit 2
  fi
fi

exit 0
