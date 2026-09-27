#!/usr/bin/env bash
# check-traceability.sh <session-dir>
# REQ-011 gate for the Test milestone: every REQ-* in the session's
# requirements file must have at least one VER-* row in verification.md
# that covers it with a passing result. Prints the missing REQ ids and
# exits 1 if any are missing; exits 0 (ok) otherwise.
#
# The requirements file is define/requirements.md (the define/ folder
# layout, #23 DES-019). A past session that predates it keeps a root
# requirements.md and is never migrated (D6), so that's the fallback. A
# session uses one layout; if both somehow exist, define/ wins. Only the
# first column of `| REQ-nnn |` rows is read, so extra columns (Priority,
# Serves), struck-through rows and `## Deferred` rows (which start with
# the follow-up issue) are all ignored.

set -uo pipefail

session_dir="${1:?Usage: check-traceability.sh <session-dir>}"
define_req_file="$session_dir/define/requirements.md"
root_req_file="$session_dir/requirements.md"
ver_file="$session_dir/verification.md"

if [[ -f "$define_req_file" ]]; then
  req_file="$define_req_file"
elif [[ -f "$root_req_file" ]]; then
  req_file="$root_req_file"
else
  echo "check-traceability: requirements not found: neither $define_req_file nor $root_req_file exists" >&2
  exit 1
fi
if [[ ! -f "$ver_file" ]]; then
  echo "check-traceability: verification.md not found: $ver_file" >&2
  exit 1
fi

# REQ ids: first column of a `| REQ-nnn | ... |` table row.
mapfile -t req_ids < <(grep -oE '^\| *REQ-[0-9]+' "$req_file" | grep -oE 'REQ-[0-9]+' | sort -u)

if [[ ${#req_ids[@]} -eq 0 ]]; then
  echo "check-traceability: no REQ-* rows found in $req_file — nothing to check"
  exit 0
fi

# REQ ids covered by a passing VER row: `| VER-nnn | Covers REQ | Method |
# Result | Evidence |`. A row counts as passing when its Result column
# contains "pass" (case-insensitive). Covers REQ may list more than one id.
passing_reqs="$(
  grep -E '^\| *VER-[0-9]+' "$ver_file" | while IFS='|' read -r _ _id covers _method result _evidence _rest; do
    result_lc="$(echo "$result" | tr '[:upper:]' '[:lower:]')"
    if [[ "$result_lc" == *pass* ]]; then
      echo "$covers" | tr ',' '\n'
    fi
  done | grep -oE 'REQ-[0-9]+' | sort -u
)"

missing=()
for id in "${req_ids[@]}"; do
  if ! grep -qxF "$id" <<<"$passing_reqs"; then
    missing+=("$id")
  fi
done

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "check-traceability: missing a passing VER for:"
  for id in "${missing[@]}"; do
    echo "  - $id"
  done
  exit 1
fi

echo "ok: every REQ-* in $req_file has a passing VER-* in $ver_file"
exit 0
