#!/usr/bin/env bash
# session-start.sh
# SessionStart hook. When the session was started as the session
# orchestrator (`agent_type` is `compass-labs:orchestrator`, or a bare
# `orchestrator` in case plugin namespacing differs — D3, P8), scans
# docs/sessions/*/log.md (never docs/sessions/archive/) frontmatter for
# `status: active` or `status: paused` and prints a short "Active
# sessions" list to stdout as context for the orchestrator's first reply
# (REQ-008, REQ-015).
#
# SessionStart can't meaningfully block startup, so this hook ALWAYS
# exits 0 — on any problem (jq missing, no sessions, wrong agent_type) it
# just prints nothing extra and gets out of the way.

set -uo pipefail

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

repo_root="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "$repo_root" ]] || repo_root="$cwd"

sessions_dir="$repo_root/docs/sessions"

active_lines=()

if [[ -d "$sessions_dir" ]]; then
for log_path in "$sessions_dir"/*/log.md; do
  [[ -f "$log_path" ]] || continue

  # Never archive/log.md — archive/ isn't a session folder under this scan
  # anyway (docs/sessions/archive/<slug>/log.md doesn't match */log.md's
  # single-directory-deep glob), but guard explicitly in case that ever
  # changes.
  case "$log_path" in
    "$sessions_dir"/archive/*) continue ;;
  esac

  frontmatter="$(awk '/^---$/{n++; next} n==1' "$log_path")"
  status="$(echo "$frontmatter" | sed -n 's/^status:[[:space:]]*//p' | head -1)"

  case "$status" in
    active|paused) ;;
    *) continue ;;
  esac

  slug="$(echo "$frontmatter" | sed -n 's/^session:[[:space:]]*//p' | head -1)"
  [[ -n "$slug" ]] || slug="$(basename "$(dirname "$log_path")")"
  issue="$(echo "$frontmatter" | sed -n 's/^issue:[[:space:]]*//p' | head -1)"
  phase="$(echo "$frontmatter" | sed -n 's/^phase:[[:space:]]*//p' | head -1)"
  next_step="$(echo "$frontmatter" | sed -n 's/^next_step:[[:space:]]*//p' | head -1)"
  # Strip surrounding quotes from next_step if present.
  next_step="${next_step%\"}"
  next_step="${next_step#\"}"

  active_lines+=("- ${slug} (#${issue:-?}, ${status}) — phase: ${phase:-?} — next: ${next_step:-?}")
done
fi

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
