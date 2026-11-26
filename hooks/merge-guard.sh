#!/usr/bin/env bash
# merge-guard.sh
# PreToolUse hook for Bash (ADR-011, ADR-012). Only the user merges. In every
# Claude Code session with trellis enabled, including unattended
# controller runs and pstack playbooks such as `shipping` and
# `autopilot-full` that would merge, it blocks:
#   - `gh pr merge …`
#   - `gh api …/pulls/{n}/merge` and `gh api …/merges`
#   - a `git push` whose destination is the default branch (any refspec
#     form, HEAD while it's checked out, --all/--mirror/--branches, a bare
#     push on the default branch, force or delete)
# Pushing feature branches, including force-pushes after a rebase, is
# allowed.
#
# The user can opt a session out by starting Claude Code with
# TRELLIS_ALLOW_MERGE=1 in its environment. The controller never sets it.
#
# Exit 2 (reason on stderr) blocks; exit 0 allows. Fails OPEN with a warning
# when jq is missing, the directory isn't a git repository, or the default
# branch can't be named: a publicly distributed plugin must never be the
# reason a repo can't work. Reads command text, so `sh -c`, `eval`, aliases
# and scripts can get past it (see hooks/lib/git-command.sh).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TAG="[merge-guard]"

input="$(cat)"

# Fast exit for every Bash call that can't be a merge or a push.
[[ "$input" == *merge* || "$input" == *push* ]] || exit 0
[[ "${TRELLIS_ALLOW_MERGE:-}" == "1" ]] && exit 0

if ! command -v jq >/dev/null 2>&1; then
  echo "$TAG WARNING: jq not found — allowing the command unchecked (fail open)" >&2
  exit 0
fi

tool_name="$(jq -r '.tool_name // empty' <<<"$input" 2>/dev/null)"
command_text="$(jq -r '.tool_input.command // empty' <<<"$input" 2>/dev/null)"
cwd="$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null)"
[[ -n "$cwd" ]] || cwd="$(pwd)"
[[ "$tool_name" == "Bash" && -n "$command_text" ]] || exit 0

# shellcheck source=lib/git-command.sh
source "$SCRIPT_DIR/lib/git-command.sh"
tokenize "$command_text"

block() {
  echo "$TAG BLOCKED: $1 Only the user merges (ADR-012). Push the feature branch and open or update its pull request instead. To merge yourself, use the GitHub UI or your own terminal." >&2
  exit 2
}

base_dir="$cwd"
for segment in "${SEGMENTS[@]:-}"; do
  [[ -n "$segment" ]] || continue
  IFS="$US" read -r -d '' -a words < <(printf '%s' "$segment")

  while [[ ${#words[@]} -gt 0 ]]; do
    case "${words[0]}" in
      *=*) [[ "${words[0]}" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]] || break; words=("${words[@]:1}") ;;
      env|command|exec|time|nohup|builtin|'{'|'}') words=("${words[@]:1}") ;;
      *) break ;;
    esac
  done
  [[ ${#words[@]} -gt 0 ]] || continue

  if [[ "${words[0]}" == "cd" ]]; then
    if [[ ${#words[@]} -ge 2 && "${words[1]}" != "-" ]]; then
      base_dir="$(resolve_dir "$base_dir" "${words[1]}")"
    elif [[ ${#words[@]} -eq 1 ]]; then
      base_dir="${HOME:-$base_dir}"
    fi
    continue
  fi

  prog="$(basename -- "${words[0]}")"

  # --- gh ------------------------------------------------------------
  if [[ "$prog" == "gh" ]]; then
    rest=("${words[@]:1}")
    # Skip gh's global flags (-R/--repo take a value).
    while [[ ${#rest[@]} -gt 0 && "${rest[0]}" == -* ]]; do
      case "${rest[0]}" in -R|--repo|--hostname) rest=("${rest[@]:2}") ;; *) rest=("${rest[@]:1}") ;; esac
    done
    if [[ "${rest[0]:-}" == "pr" && "${rest[1]:-}" == "merge" ]]; then
      block "\`gh pr merge\` merges a pull request."
    fi
    if [[ "${rest[0]:-}" == "api" ]]; then
      for w in "${rest[@]:1}"; do
        if [[ "$w" =~ /pulls/[0-9{}a-z_]+/merge$ || "$w" =~ (^|/)merges$ ]]; then
          block "\`gh api $w\` merges through the REST API."
        fi
      done
    fi
    continue
  fi

  # --- git push ------------------------------------------------------
  [[ "$prog" == "git" ]] || continue
  dir="$base_dir" sub="" idx=1
  while [[ $idx -lt ${#words[@]} ]]; do
    a="${words[$idx]}"
    case "$a" in
      -C) dir="$(resolve_dir "$dir" "${words[$((idx + 1))]:-.}")"; idx=$((idx + 2)) ;;
      -C*) dir="$(resolve_dir "$dir" "${a#-C}")"; idx=$((idx + 1)) ;;
      -c|--git-dir|--work-tree|--namespace|--config-env|--super-prefix) idx=$((idx + 2)) ;;
      -*) idx=$((idx + 1)) ;;
      *) sub="$a"; idx=$((idx + 1)); break ;;
    esac
  done
  [[ "$sub" == "push" ]] || continue

  root="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || true)"
  if [[ -z "$root" ]]; then
    echo "$TAG WARNING: $dir isn't a git repository — allowing 'git push' (fail open)" >&2
    continue
  fi
  default="$(bash "$SCRIPT_DIR/lib/default-branch.sh" "$root" 2>/dev/null || true)"
  if [[ -z "$default" ]]; then
    echo "$TAG WARNING: couldn't name the default branch of $root — allowing 'git push' (fail open)" >&2
    continue
  fi
  current="$(git -C "$root" symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
  if push_targets_default "$default" "$current" "${words[@]:$idx}"; then
    block "This push goes to \`$default\`, the default branch."
  fi
done

exit 0
