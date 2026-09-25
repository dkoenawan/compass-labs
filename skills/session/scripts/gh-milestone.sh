#!/usr/bin/env bash
# gh-milestone.sh <issue> <from-phase|none> <to-phase> <comment-file>
# Milestone-transition sync for a session (D5): swaps the issue's
# `phase:*` label and posts the milestone comment. Idempotent both ways,
# checked against the full end state rather than a single label:
#   - labels: the target state is "phase:<to-phase> present AND no other
#     phase:* label". Any stale phase:* label is removed (not just
#     phase:<from-phase> — a partial failure on an earlier run can leave
#     one behind, VER-014) and phase:<to-phase> is added only if missing.
#     The swap is skipped only when that end state already holds.
#   - comment: skipped if one with the same hidden marker
#     (`<!-- compass:milestone:<to-phase> -->`) already exists.
# <from-phase> is informational (and "none" for the first milestone):
# every stale phase:* label is removed regardless of its name.
#
# On any `gh` failure, prints `SYNC_PENDING: <what failed>` to stdout and
# exits 0 — this script never writes log.md; the orchestrator logs the
# pending sync and re-runs this script at the next milestone (D5's
# "next milestone runs any pending sync first").

set -uo pipefail

issue="${1:?Usage: gh-milestone.sh <issue> <from-phase|none> <to-phase> <comment-file>}"
from_phase="${2:?}"
to_phase="${3:?}"
comment_file="${4:?}"

if [[ ! -f "$comment_file" ]]; then
  echo "gh-milestone.sh: comment file not found: $comment_file" >&2
  exit 1
fi

marker="<!-- compass:milestone:${to_phase} -->"
to_label="phase:${to_phase}"

# --- Label swap ------------------------------------------------------
current_labels="$(gh issue view "$issue" --json labels --jq '.labels[].name' 2>&1)"
if [[ $? -ne 0 ]]; then
  echo "SYNC_PENDING: could not read labels for issue #$issue: $current_labels"
else
  has_to=false
  grep -qxF "$to_label" <<<"$current_labels" && has_to=true
  mapfile -t stale_labels < <(grep -x 'phase:.*' <<<"$current_labels" | grep -vxF "$to_label" || true)

  if [[ "$has_to" == true && ${#stale_labels[@]} -eq 0 ]]; then
    echo "ok: issue #$issue already has $to_label and no other phase:* label — label swap skipped"
  else
    swap_ok=true
    for stale in "${stale_labels[@]}"; do
      [[ -n "$stale" ]] || continue
      if ! remove_out="$(gh issue edit "$issue" --remove-label "$stale" 2>&1)"; then
        echo "SYNC_PENDING: could not remove label '$stale' from issue #$issue: $remove_out"
        swap_ok=false
      fi
    done
    if [[ "$has_to" != true ]]; then
      if ! add_out="$(gh issue edit "$issue" --add-label "$to_label" 2>&1)"; then
        echo "SYNC_PENDING: could not add label '$to_label' to issue #$issue: $add_out"
        swap_ok=false
      fi
    fi
    [[ "$swap_ok" == true ]] && echo "ok: issue #$issue moved to $to_label"
  fi
fi

# --- Milestone comment (idempotent via hidden marker) -----------------
existing_comments="$(gh issue view "$issue" --json comments --jq '.comments[].body' 2>&1)"
if [[ $? -ne 0 ]]; then
  echo "SYNC_PENDING: could not read comments for issue #$issue: $existing_comments"
  exit 0
fi

if grep -qF "$marker" <<<"$existing_comments"; then
  echo "ok: milestone comment for $to_phase already posted on issue #$issue — skipped"
  exit 0
fi

tmp_comment="$(mktemp)"
trap 'rm -f "$tmp_comment"' EXIT
cat "$comment_file" > "$tmp_comment"
printf '\n%s\n' "$marker" >> "$tmp_comment"

if ! comment_out="$(gh issue comment "$issue" --body-file "$tmp_comment" 2>&1)"; then
  echo "SYNC_PENDING: could not post milestone comment on issue #$issue: $comment_out"
  exit 0
fi

echo "ok: posted milestone comment ($to_phase) on issue #$issue"
exit 0
