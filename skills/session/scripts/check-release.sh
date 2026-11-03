#!/usr/bin/env bash
# check-release.sh <session-dir>
# Deploy-gate check (#30 DES-006, REQ-015): reads release.md's confirmed
# "Deploy tier: {tier}: {reason}" line and checks its H2 headings against
# the sections that tier requires, by the Deploy standard's tier table
# (skills/deploy/SKILL.md, section 5). Prints each missing one, e.g.
# "rollback missing", and exits 1; prints "ok" and exits 0 when all are
# present. Run it after the user has confirmed (or changed) the tier.
#
# A record with no Deploy tier line is a past record: it prints "past
# record: no check" and exits 0.

set -uo pipefail

session_dir="${1:?Usage: check-release.sh <session-dir>}"
record="$session_dir/release.md"

if [[ ! -f "$record" ]]; then
  echo "check-release: release record not found: $record" >&2
  exit 1
fi

tier_line="$(grep -m1 -E '^>?[[:space:]]*Deploy tier:' "$record" || true)"
if [[ -z "$tier_line" ]]; then
  echo "check-release: past record: no check ($record has no Deploy tier line)"
  exit 0
fi

tier="$(sed -E 's/^>?[[:space:]]*Deploy tier:[[:space:]]*([A-Za-z]+).*/\1/' <<<"$tier_line" | tr '[:upper:]' '[:lower:]')"

# The tier table: the sections each tier requires.
always=("Lifecycles run and why" "Completeness" "Change record")
case "$tier" in
  skip) required=("${always[@]}") ;;
  short) required=("${always[@]}" "Steps run" "Confirmation" "Rollback") ;;
  full) required=("${always[@]}" "Release strategy" "Steps run" "Confirmation" "Rollback") ;;
  *)
    echo "check-release: tier not recognised in '$tier_line' (skip, short or full)"
    exit 1
    ;;
esac

missing=0
for heading in "${required[@]}"; do
  # A level-2 heading, exactly, allowing trailing spaces.
  if ! grep -qE "^## ${heading}[[:space:]]*$" "$record"; then
    echo "check-release: $(tr '[:upper:]' '[:lower:]' <<<"${heading:0:1}")${heading:1} missing"
    missing=1
  fi
done

if [[ $missing -ne 0 ]]; then
  echo "check-release: refuse the Deploy milestone: release.md lacks a section the $tier tier requires" >&2
  exit 1
fi

echo "check-release: ok ($tier tier: every required section present)"
exit 0
