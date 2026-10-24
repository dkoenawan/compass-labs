#!/usr/bin/env bash
# session-branch-guard.sh
# PreToolUse hook for Bash (#37 DES-003, REQ-005, REQ-006, D1, D2). Blocks
# a session `git commit` made while the default branch is checked out, and
# a session `git push` whose destination is the default branch, so session
# work reaches the default branch only through a pull request.
#
# What counts as a session commit (D2): `list-sessions.sh` prints any
# active or paused session (in the working tree or at the tip of any local
# branch), or the index has staged paths under docs/sessions/. With no
# session open, Claude's commits and pushes are left alone. The user's own
# terminal git never passes through this hook.
#
# How the command is read: the command text is split into simple commands
# on `&&`, `||`, `;`, `|`, `&`, parentheses and newlines (quotes and
# backslashes respected, redirections dropped). A simple command is a git
# invocation when its first word (after `VAR=value` assignments and an
# `env`/`command`/`exec`/`time`/`nohup` prefix) is `git`; git's global
# options are skipped and `git -C dir` is honoured, as is an earlier
# `cd dir` in the same compound command. Then:
#   - `commit` is blocked when the current branch is the default branch.
#   - `push` is blocked when a refspec's destination is the default branch
#     (`main`, `HEAD:main`, `refs/heads/main`, `+main`, `:main`, or `HEAD`
#     while it's checked out), for `--all`, `--mirror` or `--branches`,
#     and with no refspec while the default branch is checked out.
#
# Known gap (accepted in D1, see the design's Risks): this reads command
# text, so `sh -c "git commit"`, `eval`, a git alias, an unquoted heredoc
# body, or a script that commits can get past it.
#
# The default branch comes from skills/session/scripts/default-branch.sh
# and the session list from skills/session/scripts/list-sessions.sh, both
# resolved relative to this file (plugin paths, never the project's).
#
# Exit 2 (reason on stderr) blocks the command; exit 0 allows it. Fails
# OPEN with a warning on stderr when jq is missing, the directory isn't a
# git repository, a collaborator script is missing, or default-branch.sh
# can't answer: this plugin is publicly distributed and must never be the
# reason a repo can't work ("Hooks fail open").

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEFAULT_BRANCH_SCRIPT="$PLUGIN_ROOT/skills/session/scripts/default-branch.sh"
LIST_SESSIONS_SCRIPT="$PLUGIN_ROOT/skills/session/scripts/list-sessions.sh"

TAG="[session-branch-guard]"

input="$(cat)"

# Fast exit for every Bash call that can't be a git commit or push.
mentions_git_write() {
  [[ "$1" == *git* ]] && [[ "$1" == *commit* || "$1" == *push* ]]
}

mentions_git_write "$input" || exit 0

if ! command -v jq >/dev/null 2>&1; then
  echo "$TAG WARNING: jq not found — allowing the command without checking for the default branch (fail open)" >&2
  exit 0
fi

tool_name="$(jq -r '.tool_name // empty' <<<"$input" 2>/dev/null)"
command_text="$(jq -r '.tool_input.command // empty' <<<"$input" 2>/dev/null)"
cwd="$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null)"
[[ -n "$cwd" ]] || cwd="$(pwd)"

[[ "$tool_name" == "Bash" ]] || exit 0
[[ -n "$command_text" ]] || exit 0
mentions_git_write "$command_text" || exit 0

# --- Tokenizer ---------------------------------------------------------
# Splits command_text into simple commands. Each entry of SEGMENTS is one
# simple command's words joined with the unit separator (\x1f).
US=$'\x1f'
SEGMENTS=()

tokenize() {
  local s="$1" n=${#1} i=0 c next
  local tok="" have=0 in_single=0 in_double=0
  local -a seg=()

  flush_tok() {
    if [[ $have -eq 1 ]]; then seg+=("$tok"); fi
    tok=""; have=0
  }
  flush_seg() {
    flush_tok
    if [[ ${#seg[@]} -gt 0 ]]; then
      local IFS="$US"
      SEGMENTS+=("${seg[*]}")
    fi
    seg=()
  }

  while [[ $i -lt $n ]]; do
    c="${s:i:1}"
    if [[ $in_single -eq 1 ]]; then
      if [[ "$c" == "'" ]]; then in_single=0; else tok+="$c"; fi
      i=$((i + 1)); continue
    fi
    if [[ $in_double -eq 1 ]]; then
      if [[ "$c" == '"' ]]; then
        in_double=0
      elif [[ "$c" == '\' ]]; then
        next="${s:i+1:1}"
        case "$next" in
          '"'|'\'|'$'|'`') tok+="$next"; i=$((i + 1)) ;;
          *) tok+="$c" ;;
        esac
      else
        tok+="$c"
      fi
      i=$((i + 1)); continue
    fi
    case "$c" in
      "'") in_single=1; have=1 ;;
      '"') in_double=1; have=1 ;;
      '\')
        next="${s:i+1:1}"
        if [[ "$next" != $'\n' && -n "$next" ]]; then tok+="$next"; have=1; fi
        i=$((i + 1))
        ;;
      ' '|$'\t') flush_tok ;;
      $'\n'|';'|'|'|'&'|'('|')') flush_seg ;;
      '>'|'<')
        # A redirection: drop a leading fd number, the operator and its
        # target, so none of them reads as a git argument.
        if [[ "$tok" =~ ^[0-9]+$ ]]; then tok=""; have=0; fi
        flush_tok
        while [[ $i -lt $n && "${s:i:1}" == [\<\>] ]]; do i=$((i + 1)); done
        if [[ "${s:i:1}" == '&' ]]; then
          i=$((i + 1))
          while [[ $i -lt $n && "${s:i:1}" =~ [0-9-] ]]; do i=$((i + 1)); done
        else
          while [[ $i -lt $n && "${s:i:1}" =~ [[:blank:]] ]]; do i=$((i + 1)); done
          while [[ $i -lt $n && ! "${s:i:1}" =~ [[:space:]\;\|\&\(\)] ]]; do i=$((i + 1)); done
        fi
        continue
        ;;
      *) tok+="$c"; have=1 ;;
    esac
    i=$((i + 1))
  done
  flush_seg
}

tokenize "$command_text"

# resolve_dir <base> <path>
resolve_dir() {
  local base="$1" p="$2"
  case "$p" in
    /*) echo "$p" ;;
    "~") echo "${HOME:-$base}" ;;
    "~/"*) echo "${HOME:-$base}/${p#\~/}" ;;
    *) echo "$base/$p" ;;
  esac
}

# --- Session and branch facts, computed once per directory -------------
declare -A REPO_OF=() IS_SESSION=() DEFAULT_OF=() CURRENT_OF=()

# repo_facts <dir> : sets FACT_REPO, FACT_SESSION (true|false),
# FACT_DEFAULT (empty = unknown), FACT_CURRENT (empty = detached). Returns
# 1 (after warning) when the guard must fail open for this directory.
repo_facts() {
  local dir="$1" root
  root="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null || true)"
  if [[ -z "$root" ]]; then
    echo "$TAG WARNING: $dir isn't a git repository — allowing the command (fail open)" >&2
    return 1
  fi
  FACT_REPO="$root"
  if [[ -n "${IS_SESSION[$root]:-}" ]]; then
    FACT_SESSION="${IS_SESSION[$root]}"
    FACT_DEFAULT="${DEFAULT_OF[$root]}"
    FACT_CURRENT="${CURRENT_OF[$root]}"
    return 0
  fi

  if [[ ! -f "$LIST_SESSIONS_SCRIPT" || ! -f "$DEFAULT_BRANCH_SCRIPT" ]]; then
    echo "$TAG WARNING: list-sessions.sh or default-branch.sh not found under $PLUGIN_ROOT — allowing the command (fail open)" >&2
    return 1
  fi

  FACT_SESSION=false
  if [[ -n "$(bash "$LIST_SESSIONS_SCRIPT" "$root" 2>/dev/null)" ]]; then
    FACT_SESSION=true
  elif [[ -n "$(git -C "$root" diff --cached --name-only -- docs/sessions/ 2>/dev/null)" ]]; then
    FACT_SESSION=true
  fi

  FACT_DEFAULT=""
  if [[ "$FACT_SESSION" == true ]]; then
    FACT_DEFAULT="$(bash "$DEFAULT_BRANCH_SCRIPT" "$root" 2>/dev/null || true)"
  fi
  FACT_CURRENT="$(git -C "$root" symbolic-ref --quiet --short HEAD 2>/dev/null || true)"

  IS_SESSION["$root"]="$FACT_SESSION"
  DEFAULT_OF["$root"]="$FACT_DEFAULT"
  CURRENT_OF["$root"]="$FACT_CURRENT"
  return 0
}

block() {
  local default="$1" detail="$2"
  echo "$TAG BLOCKED: \`$default\` is this repository's default branch; session commits reach it only through a pull request (REQ-005). $detail" >&2
  exit 2
}

# push_targets_default <default> <current> <args...> : returns 0 when this
# push's destination is the default branch.
push_targets_default() {
  local default="$1" current="$2"; shift 2
  local -a positional=()
  local repo_given=0 all=0 a dst
  while [[ $# -gt 0 ]]; do
    a="$1"; shift
    case "$a" in
      --) positional+=("$@"); break ;;
      --all|--mirror|--branches) all=1 ;;
      --repo=*) repo_given=1 ;;
      --repo) repo_given=1; shift ;;
      -o|--push-option|--receive-pack|--exec) shift ;;
      -*) ;;
      *) positional+=("$a") ;;
    esac
  done
  [[ $all -eq 1 ]] && return 0

  local -a refspecs=()
  if [[ $repo_given -eq 1 ]]; then
    refspecs=("${positional[@]:0}")
  else
    refspecs=("${positional[@]:1}")
  fi

  if [[ ${#refspecs[@]} -eq 0 ]]; then
    [[ -n "$current" && "$current" == "$default" ]] && return 0
    return 1
  fi

  local r
  for r in "${refspecs[@]}"; do
    r="${r#+}"
    if [[ "$r" == *:* ]]; then dst="${r#*:}"; else dst="$r"; fi
    [[ "$dst" == "HEAD" || "$dst" == "@" ]] && dst="$current"
    dst="${dst#refs/heads/}"
    [[ -n "$dst" ]] || continue
    if [[ "$dst" == "$default" ]]; then return 0; fi
    # shellcheck disable=SC2053 # a wildcard refspec destination is a glob
    if [[ "$dst" == *'*'* && "$default" == $dst ]]; then return 0; fi
  done
  return 1
}

# --- Walk every simple command -----------------------------------------
base_dir="$cwd"

for segment in "${SEGMENTS[@]:-}"; do
  [[ -n "$segment" ]] || continue
  # -d '' so a quoted word holding a newline (a commit message) stays whole.
  IFS="$US" read -r -d '' -a words < <(printf '%s' "$segment")

  # Skip assignments and harmless prefixes.
  while [[ ${#words[@]} -gt 0 ]]; do
    case "${words[0]}" in
      *=*) [[ "${words[0]}" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]] || break; words=("${words[@]:1}") ;;
      env|command|exec|time|nohup|builtin|'{'|'}') words=("${words[@]:1}") ;;
      *) break ;;
    esac
  done
  [[ ${#words[@]} -gt 0 ]] || continue

  # `cd dir` changes where later git commands in this compound run.
  if [[ "${words[0]}" == "cd" ]]; then
    if [[ ${#words[@]} -ge 2 && "${words[1]}" != "-" ]]; then
      base_dir="$(resolve_dir "$base_dir" "${words[1]}")"
    elif [[ ${#words[@]} -eq 1 ]]; then
      base_dir="${HOME:-$base_dir}"
    fi
    continue
  fi

  [[ "$(basename -- "${words[0]}")" == "git" ]] || continue

  dir="$base_dir"
  sub=""
  idx=1
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

  case "$sub" in
    commit|push) ;;
    *) continue ;;
  esac

  repo_facts "$dir" || exit 0
  [[ "$FACT_SESSION" == true ]] || continue

  if [[ -z "$FACT_DEFAULT" ]]; then
    echo "$TAG WARNING: default-branch.sh couldn't name the default branch for $FACT_REPO — allowing 'git $sub' (fail open)" >&2
    continue
  fi

  if [[ "$sub" == "commit" ]]; then
    if [[ -n "$FACT_CURRENT" && "$FACT_CURRENT" == "$FACT_DEFAULT" ]]; then
      block "$FACT_DEFAULT" "Switch to the session branch (its log.md's \`branch:\`) or create one, then commit there."
    fi
    continue
  fi

  if push_targets_default "$FACT_DEFAULT" "$FACT_CURRENT" "${words[@]:$idx}"; then
    block "$FACT_DEFAULT" "Push the session branch instead, e.g. \`git push -u origin {session-branch}\`, and open a pull request."
  fi
done

exit 0
