#!/usr/bin/env bash
# check-design.sh <session-dir>
# Design-gate check (#27 DES-011, REQ-017): before the Design milestone is
# recorded, a session's design/index.md must have the four sections the gate
# relies on: Classification (the solution kind), Scope checklist, Context
# view and Delta list. Prints each missing one, e.g. "delta list missing",
# and exits 1; prints "ok" and exits 0 when all are present.
#
# A past session that predates the design/ folder keeps its root design.md
# and is never migrated (D6, REQ-024). With only design.md there, no new
# check applies: it prints "legacy layout: no check" and exits 0. A session
# uses one layout; if both somehow exist, design/ wins.

set -uo pipefail

session_dir="${1:?Usage: check-design.sh <session-dir>}"
index_file="$session_dir/design/index.md"
legacy_file="$session_dir/design.md"

if [[ ! -f "$index_file" ]]; then
  if [[ -f "$legacy_file" ]]; then
    echo "check-design: legacy layout: no check ($legacy_file)"
    exit 0
  fi
  echo "check-design: design not found: neither $index_file nor $legacy_file exists" >&2
  exit 1
fi

# heading -> what to call it when it's missing
required=(
  "Classification|classification"
  "Scope checklist|scope checklist"
  "Context view|context view"
  "Delta list|delta list"
)

missing=0
for entry in "${required[@]}"; do
  heading="${entry%%|*}"
  label="${entry#*|}"
  # A level-2 heading, exactly, allowing trailing spaces.
  if ! grep -qE "^## ${heading}[[:space:]]*$" "$index_file"; then
    echo "check-design: $label missing"
    missing=1
  fi
done

if [[ $missing -ne 0 ]]; then
  echo "check-design: refuse the Design milestone until design/index.md has every section above" >&2
  exit 1
fi

echo "check-design: ok (classification, scope checklist, context view and delta list present)"
exit 0
