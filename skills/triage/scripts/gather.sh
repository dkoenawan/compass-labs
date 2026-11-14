#!/usr/bin/env bash
# gather.sh
# Read-only snapshot of a repository's open issues for a triage stock-take.
#
# Usage:
#   gather.sh <repo> <out-dir> [--report N] [--prs N]
#
#   <repo>        Path to the local git repository (gh reads its GitHub remote).
#   <out-dir>     Directory to write the snapshot to (created if missing).
#   --report N    Also write changed.json: the issues in report issue #N that
#                 were updated or closed after #N was created (REQ-017).
#   --prs N       How many recently merged pull requests to read (default 200).
#
# Writes to <out-dir>:
#   issues.json      open issues (number, title, body, labels, comments, author,
#                    createdAt, updatedAt), report issues removed (D7)
#   reports.json     open report issues: title "Triage YYYY-MM-DD" by the viewer
#   merged-prs.json  the last N merged PRs (number, title, body, mergedAt, files)
#   anchor.md        the README text between the compass:anchor markers, if any
#   meta.json        repo, viewer, label_exists, branch, head, anchor
#   changed.json     only with --report N
#
# Only reads: gh issue list/view, gh pr list, gh label list, gh api user and
# git rev-parse. Exits non-zero with a message on any gh failure.
# The gh binary is TRIAGE_GH_BIN if set, else gh on PATH.

set -euo pipefail

SCRIPT_NAME="gather.sh"
REPORT_TITLE_RE='^Triage [0-9]{4}-[0-9]{2}-[0-9]{2}$'

die() { echo "[$SCRIPT_NAME] Error: $*" >&2; exit 1; }

REPO="" OUT="" REPORT="" PRS=200
while [[ $# -gt 0 ]]; do
  case "$1" in
    --report) [[ "${2:-}" =~ ^[0-9]+$ ]] || die "--report needs an issue number"; REPORT="$2"; shift 2 ;;
    --prs) [[ "${2:-}" =~ ^[0-9]+$ ]] || die "--prs needs a number"; PRS="$2"; shift 2 ;;
    -h|--help) sed -n '2,27p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) die "unknown option '$1'" ;;
    *)
      if [[ -z "$REPO" ]]; then REPO="$1"
      elif [[ -z "$OUT" ]]; then OUT="$1"
      else die "unexpected argument '$1'"
      fi
      shift ;;
  esac
done
[[ -n "$REPO" && -n "$OUT" ]] || die "usage: $SCRIPT_NAME <repo> <out-dir> [--report N] [--prs N]"
[[ -d "$REPO" ]] || die "'$REPO' is not a directory"
command -v jq >/dev/null 2>&1 || die "jq not found"
GH="${TRIAGE_GH_BIN:-gh}"
command -v "$GH" >/dev/null 2>&1 || die "gh not found ($GH)"

REPO_ABS="$(cd "$REPO" && pwd)"
git -C "$REPO_ABS" rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "'$REPO_ABS' is not a git repository"
mkdir -p "$OUT"

# gh_read <what> <args...>: runs a read-only gh call from the repo directory,
# printing its stdout; exits with a message naming <what> if it fails.
gh_read() {
  local what="$1" out
  shift
  if ! out="$(cd "$REPO_ABS" && "$GH" "$@")"; then
    die "gh failed while reading $what"
  fi
  printf '%s\n' "$out"
}

VIEWER="$(gh_read "the authenticated user" api user --jq .login)"
[[ -n "$VIEWER" ]] || die "gh api user returned no login"

ALL_OPEN="$(gh_read "open issues" issue list --state open --limit 1000 \
  --json number,title,body,labels,comments,author,createdAt,updatedAt)"

is_report='(.title | test($re)) and (.author.login == $viewer)'
jq --arg re "$REPORT_TITLE_RE" --arg viewer "$VIEWER" "[.[] | select(($is_report) | not)]" \
  <<<"$ALL_OPEN" >"$OUT/issues.json"
jq --arg re "$REPORT_TITLE_RE" --arg viewer "$VIEWER" "[.[] | select($is_report)]" \
  <<<"$ALL_OPEN" >"$OUT/reports.json"

gh_read "merged pull requests" pr list --state merged --limit "$PRS" \
  --json number,title,body,mergedAt,files >"$OUT/merged-prs.json"

LABELS="$(gh_read "labels" label list --limit 1000 --json name)"
LABEL_EXISTS="$(jq 'any(.[]; .name == "triage")' <<<"$LABELS")"

# The anchor: the README text strictly between the two markers.
ANCHOR=missing
rm -f "$OUT/anchor.md"
if [[ -f "$REPO_ABS/README.md" ]] && grep -qx '<!-- compass:anchor -->' "$REPO_ABS/README.md" \
  && grep -qx '<!-- /compass:anchor -->' "$REPO_ABS/README.md"; then
  awk '/^<!-- \/compass:anchor -->$/ {exit} inside {print} /^<!-- compass:anchor -->$/ {inside=1}' \
    "$REPO_ABS/README.md" >"$OUT/anchor.md"
  if [[ -s "$OUT/anchor.md" ]]; then ANCHOR=found; else rm -f "$OUT/anchor.md"; fi
fi

BRANCH="$(git -C "$REPO_ABS" rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
HEAD_SHA="$(git -C "$REPO_ABS" rev-parse HEAD 2>/dev/null || echo unknown)"

jq -n --arg repo "$REPO_ABS" --arg viewer "$VIEWER" --argjson label "$LABEL_EXISTS" \
  --arg branch "$BRANCH" --arg head "$HEAD_SHA" --arg anchor "$ANCHOR" \
  '{repo:$repo, viewer:$viewer, label_exists:$label, branch:$branch, head:$head, anchor:$anchor}' \
  >"$OUT/meta.json"

# --report N: the issues in report N changed since N was created (REQ-017).
if [[ -n "$REPORT" ]]; then
  REPORT_JSON="$(gh_read "report issue #$REPORT" issue view "$REPORT" \
    --json number,title,body,author,createdAt,state)"
  jq -e --arg re "$REPORT_TITLE_RE" --arg viewer "$VIEWER" "$is_report" <<<"$REPORT_JSON" >/dev/null \
    || die "#$REPORT is not a report issue (title 'Triage YYYY-MM-DD' by $VIEWER)"
  CREATED="$(jq -r '.createdAt' <<<"$REPORT_JSON")"
  mapfile -t NUMBERS < <(jq -r '.body' <<<"$REPORT_JSON" \
    | grep -oE '^### #[0-9]+:' | grep -oE '[0-9]+' | sort -un)
  changed='[]'
  for n in "${NUMBERS[@]}"; do
    ISSUE="$(gh_read "issue #$n" issue view "$n" --json number,title,state,updatedAt,closedAt)"
    changed="$(jq --argjson issue "$ISSUE" --arg since "$CREATED" '
      . + ( [$issue | . + {reasons: ([ (select(.updatedAt != null and .updatedAt > $since) | "updated"),
                                       (select(.closedAt != null and .closedAt > $since) | "closed") ])}]
            | map(select(.reasons | length > 0)) )' <<<"$changed")"
  done
  jq --argjson n "$REPORT" --arg since "$CREATED" '{report:$n, report_created:$since, issues:.}' \
    <<<"$changed" >"$OUT/changed.json"
fi

echo "[$SCRIPT_NAME] Snapshot written to $OUT ($(jq length "$OUT/issues.json") issues, anchor $ANCHOR, label_exists $LABEL_EXISTS)"
