#!/usr/bin/env bash
# gh-setup.sh [--repo owner/name] [--type feature]
# One-time (idempotent) GitHub label setup for a session workflow (D5).
# Creates one type:<type> label plus each phase's gh_label from
# skills/session/workflows/<type>.json, using `gh label create --force`
# so re-running it is always safe.
#
# On any `gh` failure, prints `SYNC_PENDING: <what failed>` to stdout and
# keeps going (best effort) — it never writes log.md; the orchestrator
# logs the pending sync and this script can simply be re-run later.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$SCRIPT_DIR/../../.." && pwd)}"

repo=""
type="feature"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      repo="${2:?--repo requires owner/name}"
      shift 2
      ;;
    --type)
      type="${2:?--type requires a workflow type}"
      shift 2
      ;;
    *)
      echo "gh-setup.sh: unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

workflow_file="$PLUGIN_ROOT/skills/session/workflows/${type}.json"

if ! command -v jq >/dev/null 2>&1; then
  echo "gh-setup.sh: jq not found — cannot read $workflow_file" >&2
  exit 1
fi

if [[ ! -f "$workflow_file" ]]; then
  echo "gh-setup.sh: workflow file not found: $workflow_file" >&2
  exit 1
fi

repo_args=()
[[ -n "$repo" ]] && repo_args=(--repo "$repo")

create_label() {
  local name="$1" color="$2"
  if ! out="$(gh label create "$name" --color "$color" --force "${repo_args[@]}" 2>&1)"; then
    echo "SYNC_PENDING: could not create/update label '$name': $out"
    return
  fi
  echo "ok: label '$name' ready"
}

# type:<type> label
type_label="$(jq -r '.github.type_label // empty' "$workflow_file")"
type_color="$(jq -r '.github.type_color // "A2EEEF"' "$workflow_file")"
if [[ -n "$type_label" ]]; then
  create_label "$type_label" "$type_color"
else
  create_label "type:${type}" "A2EEEF"
fi

# One phase:* label per phase.
while IFS=$'\t' read -r label color; do
  [[ -n "$label" ]] || continue
  create_label "$label" "$color"
done < <(jq -r '.phases[] | [.gh_label, (.gh_color // "6A737D")] | @tsv' "$workflow_file")

exit 0
