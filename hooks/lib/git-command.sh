#!/usr/bin/env bash
# git-command.sh
# Shared command-text reader for Bash PreToolUse hooks (sourced, not run).
# Recovered from the retired session-branch-guard.sh (ADR-012), used by
# merge-guard.sh.
#
# tokenize <text>   fills SEGMENTS: one entry per simple command, its words
#                   joined with $US. Splits on && || ; | & ( ) and newlines,
#                   respects quotes and backslashes, drops redirections.
# resolve_dir <base> <path>
# push_targets_default <default> <current> <push-args...>
#                   returns 0 when the push's destination is the default
#                   branch (refspecs, HEAD while it's checked out, --all,
#                   --mirror, --branches, or no refspec on the default).
#
# Known gap: this reads command text, so `sh -c "..."`, `eval`, aliases and
# scripts can get past any guard built on it.

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
