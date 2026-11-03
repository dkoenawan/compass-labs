#!/usr/bin/env bash
# check-declaration.sh <repo-root> [--plan]
# Validates a repo's deploy declaration, <repo-root>/.claude/deploy.json,
# against the Deploy standard (skills/deploy/SKILL.md, section 2, and
# reference/declaration.md). It reads the file only: it never runs a
# command from the repo.
#
# Reports exactly one of these, with its exit code:
#   0  valid             "check-declaration: valid"
#   1  invalid           one line per problem: "missing: rollback",
#                        "merge marked routine: step '...'",
#                        "versioning.file not found: ...",
#                        "versioning.tag has no {version}: ...", bad JSON
#   2  no declaration    the file doesn't exist; says how to declare one
#   3  none              "deployment": "none": nothing to deploy
#   4  no jq             warns and checks nothing; check the file by hand
#                        against the Deploy standard (hooks fail open)
#
# --plan (on a valid declaration) also prints, in declared order with L1
# before L2: each step with its kind and whether it may run or waits for
# the user, the release mode, and the proposed tier with its reason, both
# as is and if L1 runs. On "none" it prints the skip tier.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STANDARD_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TAG="check-declaration:"

usage() { echo "Usage: check-declaration.sh <repo-root> [--plan]" >&2; exit 1; }

root="" plan=0
for arg in "$@"; do
  case "$arg" in
    --plan) plan=1 ;;
    -*) usage ;;
    *) [[ -z "$root" ]] && root="$arg" || usage ;;
  esac
done
[[ -n "$root" ]] || usage
[[ -d "$root" ]] || { echo "$TAG repo root not found: $root" >&2; exit 1; }

decl="$root/.claude/deploy.json"

if [[ ! -f "$decl" ]]; then
  echo "$TAG no declaration: $decl not found"
  echo "$TAG Deploy needs a deploy declaration before it runs anything. Declare one at .claude/deploy.json as the Deploy standard describes: $STANDARD_DIR/SKILL.md (section 2, The deploy declaration) and $STANDARD_DIR/reference/declaration.md. A repo with nothing to deploy declares {\"deployment\": \"none\"}."
  exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "$TAG WARNING: jq not found: nothing checked. Check $decl by hand against $STANDARD_DIR/reference/declaration.md" >&2
  exit 4
fi

if ! jq -e 'type == "object"' "$decl" >/dev/null 2>&1; then
  echo "$TAG invalid: $decl isn't a JSON object"
  exit 1
fi

deployment="$(jq -r '.deployment // empty' "$decl")"
if [[ "$deployment" == "none" ]]; then
  echo "$TAG none: nothing to deploy, per the declaration"
  if [[ $plan -eq 1 ]]; then
    echo "plan: no step runs"
    echo "plan: tier: skip: nothing to deploy, per the declaration"
  fi
  exit 3
fi

# Every problem the jq rules find, one per line.
problems="$(jq -r -f "$SCRIPT_DIR/lib/validate.jq" "$decl" 2>&1)" || { echo "$TAG invalid: the declaration could not be checked: $problems"; exit 1; }

vfile="$(jq -r '.versioning.file // empty' "$decl")"
if [[ -n "$vfile" && ! -f "$root/$vfile" ]]; then
  problems+=$'\n'"versioning.file not found: $vfile"
fi
problems="$(sed '/^$/d' <<<"$problems")"

if [[ -n "$problems" ]]; then
  while IFS= read -r p; do echo "$TAG $p"; done <<<"$problems"
  echo "$TAG invalid: fix the declaration as the Deploy standard describes ($STANDARD_DIR/reference/declaration.md); no deploy step may run until it's valid" >&2
  exit 1
fi

echo "$TAG valid"
[[ $plan -eq 1 ]] || exit 0

jq -r -f "$SCRIPT_DIR/lib/plan.jq" "$decl"
exit 0
