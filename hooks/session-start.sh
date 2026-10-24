#!/usr/bin/env bash
# session-start.sh
# SessionStart hook. When the session was started as the session
# orchestrator (`agent_type` is `compass-labs:orchestrator`, or a bare
# `orchestrator` in case plugin namespacing differs — D3, P8), prints a
# short "Active sessions" list to stdout as context for the orchestrator's
# first reply (REQ-008, REQ-015).
#
# The list comes from skills/session/scripts/list-sessions.sh (#37 DES-008,
# REQ-004, D4): every active or paused session in the working tree and at
# the tip of every local branch, never docs/sessions/archive/. A session
# that isn't in the working tree is shown with `on {branch}`, and its
# issue, phase and next step are read from that branch's log.md
# (read-only, no checkout).
#
# SessionStart can't meaningfully block startup, so this hook ALWAYS
# exits 0 — on any problem (jq missing, list-sessions.sh missing, wrong
# agent_type) it just prints nothing extra and gets out of the way.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIST_SESSIONS_SCRIPT="$SCRIPT_DIR/../skills/session/scripts/list-sessions.sh"

input="$(cat)"

if ! command -v jq >/dev/null 2>&1; then
  # Fail open, silently — this hook only adds context, never blocks.
  exit 0
fi

agent_type="$(jq -r '.agent_type // empty' <<<"$input" 2>/dev/null)"
cwd="$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null)"
[[ -n "$cwd" ]] || cwd="$(pwd)"

case "$agent_type" in
  compass-labs:orchestrator|orchestrator) ;;
  *) exit 0 ;;
esac

# Without the lister there's no list to give; the skill then runs it (or
# scans) itself. Never print a misleading "none".
[[ -f "$LIST_SESSIONS_SCRIPT" ]] || exit 0

repo_root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "$repo_root" ]] || repo_root="$cwd"

current_branch="$(git -C "$repo_root" symbolic-ref --quiet --short HEAD 2>/dev/null || echo HEAD)"

field() {
  # field <frontmatter> <key>
  sed -n "s/^$2:[[:space:]]*//p" <<<"$1" | head -1
}

active_lines=()

while IFS=$'\t' read -r slug status found_on _recorded; do
  [[ -n "$slug" ]] || continue

  log_rel="docs/sessions/$slug/log.md"
  # list-sessions.sh reports a working-tree session as found on the
  # checked-out branch; anything else came from another branch's tip.
  if [[ "$found_on" == "$current_branch" && -f "$repo_root/$log_rel" ]]; then
    where=""
    content="$(cat "$repo_root/$log_rel" 2>/dev/null || true)"
  else
    where=" — on ${found_on}"
    content="$(git -C "$repo_root" show "$found_on:$log_rel" 2>/dev/null || true)"
  fi

  frontmatter="$(awk '/^---$/{n++; next} n==1' <<<"$content")"
  issue="$(field "$frontmatter" issue)"
  phase="$(field "$frontmatter" phase)"
  next_step="$(field "$frontmatter" next_step)"
  # Strip surrounding quotes from next_step if present.
  next_step="${next_step%\"}"
  next_step="${next_step#\"}"

  active_lines+=("- ${slug} (#${issue:-?}, ${status})${where} — phase: ${phase:-?} — next: ${next_step:-?}")
done < <(bash "$LIST_SESSIONS_SCRIPT" "$repo_root" 2>/dev/null)

if [[ ${#active_lines[@]} -eq 0 ]]; then
  echo "Active sessions: none. Ask the user whether to start a new one (/compass-labs:session new)."
  exit 0
fi

echo "Active sessions:"
for line in "${active_lines[@]}"; do
  echo "$line"
done
echo ""
echo "Resume one of these, or start a new session?"

exit 0
