#!/usr/bin/env bash
# list-sessions.sh [repo-path]
# Lists every active or paused session (#37 DES-002, REQ-004, REQ-005, D2,
# D4): one tab-separated line per session,
#
#   {slug}<TAB>{status}<TAB>{branch it was found on}<TAB>{recorded branch: or -}
#
# Sources, in order:
#   1. The working tree: docs/sessions/*/log.md, untracked files included.
#      A working-tree session's "found on" is the checked-out branch
#      (`HEAD` when detached).
#   2. The tip of every local branch (refs/heads), read with `git grep` and
#      `git show`: read-only, no checkout, no fetch.
#
# docs/sessions/archive/ is never read. {slug} is the session's folder
# name. A slug found in the working tree wins over any branch copy; among
# branch copies, the copy on the branch its `branch:` field names wins,
# otherwise the first branch in refname order. Only `status: active` and
# `status: paused` are listed.
#
# Always exits 0, also when nothing is listed or repo-path isn't a git
# repository (then only the working tree at repo-path is read).

set -uo pipefail

repo="${1:-.}"

root="$(git -C "$repo" rev-parse --show-toplevel 2>/dev/null || true)"
in_git=true
if [[ -z "$root" ]]; then
  in_git=false
  root="$repo"
fi

# frontmatter_field <field> : reads the frontmatter on stdin, prints the
# field's value (first match, trailing whitespace trimmed).
frontmatter_field() {
  awk -v key="$1" '
    /^---[[:space:]]*$/ { n++; if (n >= 2) exit; next }
    n == 1 {
      if (index($0, key ":") == 1) {
        v = substr($0, length(key) + 2)
        sub(/^[[:space:]]+/, "", v)
        sub(/[[:space:]]+$/, "", v)
        print v
        exit
      }
    }'
}

declare -A seen=()
lines=()

current_branch="HEAD"
if [[ "$in_git" == true ]]; then
  current_branch="$(git -C "$root" symbolic-ref --quiet --short HEAD 2>/dev/null || echo HEAD)"
fi

# 1. Working tree.
sessions_dir="$root/docs/sessions"
if [[ -d "$sessions_dir" ]]; then
  for log_path in "$sessions_dir"/*/log.md; do
    [[ -f "$log_path" ]] || continue
    slug="$(basename "$(dirname "$log_path")")"
    [[ "$slug" == "archive" ]] && continue
    content="$(cat "$log_path" 2>/dev/null || true)"
    status="$(frontmatter_field status <<<"$content")"
    case "$status" in
      active|paused) ;;
      *) continue ;;
    esac
    recorded="$(frontmatter_field branch <<<"$content")"
    [[ -n "$recorded" ]] || recorded="-"
    seen["$slug"]=1
    lines+=("$(printf '%s\t%s\t%s\t%s' "$slug" "$status" "$current_branch" "$recorded")")
  done
fi

# 2. Local branch tips.
if [[ "$in_git" == true ]]; then
  mapfile -t branches < <(git -C "$root" for-each-ref --format='%(refname:short)' refs/heads 2>/dev/null)

  declare -A pick_line=() pick_exact=()
  order=()

  if [[ ${#branches[@]} -gt 0 ]]; then
    # One git grep over every branch tip; prints "{branch}:{path}" per
    # candidate log.md. The frontmatter is parsed properly below.
    while IFS= read -r hit; do
      [[ -n "$hit" ]] || continue
      branch="${hit%%:*}"
      path="${hit#*:}"
      # Exactly docs/sessions/{slug}/log.md, never archive/.
      [[ "$path" =~ ^docs/sessions/([^/]+)/log\.md$ ]] || continue
      slug="${BASH_REMATCH[1]}"
      [[ "$slug" == "archive" ]] && continue
      [[ -n "${seen[$slug]:-}" ]] && continue

      content="$(git -C "$root" show "$branch:$path" 2>/dev/null || true)"
      status="$(frontmatter_field status <<<"$content")"
      case "$status" in
        active|paused) ;;
        *) continue ;;
      esac
      recorded="$(frontmatter_field branch <<<"$content")"
      [[ -n "$recorded" ]] || recorded="-"
      line="$(printf '%s\t%s\t%s\t%s' "$slug" "$status" "$branch" "$recorded")"

      if [[ -z "${pick_line[$slug]:-}" ]]; then
        order+=("$slug")
        pick_line["$slug"]="$line"
        [[ "$branch" == "$recorded" ]] && pick_exact["$slug"]=1
      elif [[ -z "${pick_exact[$slug]:-}" && "$branch" == "$recorded" ]]; then
        pick_line["$slug"]="$line"
        pick_exact["$slug"]=1
      fi
    done < <(git -C "$root" grep -l -E '^status:[[:space:]]*(active|paused)[[:space:]]*$' \
               "${branches[@]}" -- 'docs/sessions/*/log.md' 2>/dev/null)
  fi

  for slug in "${order[@]:-}"; do
    [[ -n "$slug" ]] || continue
    lines+=("${pick_line[$slug]}")
  done
fi

for line in "${lines[@]:-}"; do
  [[ -n "$line" ]] && printf '%s\n' "$line"
done

exit 0
