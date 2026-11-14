#!/usr/bin/env bash
# install-starter.sh <repo-root>
# Copies the Deploy standard's starter (#30 DES-015, REQ-028) into a
# GitHub-hosted repo, on the user's yes only: the offer procedure in
# skills/deploy/SKILL.md runs it, never anything else. Writes
#   .github/workflows/release.yml   from templates/github/release.yml
#   .github/scripts/release-tag.sh  from templates/github/release-tag.sh,
#                                   its settings block filled in from the
#                                   declaration's versioning.file,
#                                   versioning.field and versioning.tag
# and prints both paths. The copies belong to the repo from then on; they
# call nothing of the plugin's at run time. It adds nothing to the
# declaration: the offer procedure adds the pipeline's l1.parts entry.
#
# Writes nothing, and exits with its own code, when:
#   1  the declaration isn't valid (check-declaration.sh's message shown)
#   3  origin isn't a GitHub URL
#   4  a versioning field is missing (named)
#   5  a target file already exists (named; never overwritten)

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES="$SCRIPT_DIR/../templates/github"
TAG="install-starter:"

root="${1:?Usage: install-starter.sh <repo-root>}"
[[ -d "$root" ]] || { echo "$TAG repo root not found: $root" >&2; exit 1; }
decl="$root/.claude/deploy.json"

# The declaration must be valid and declared (not none, not missing).
check_out="$(bash "$SCRIPT_DIR/check-declaration.sh" "$root" 2>&1)"
check_status=$?
if [[ $check_status -ne 0 ]]; then
  echo "$check_out"
  echo "$TAG writing nothing: the starter takes its values from a valid deploy declaration" >&2
  exit 1
fi

# origin_host <url>: the host part of a git URL (https, ssh://, git://, or
# scp-like user@host:path); empty for a local path.
origin_host() {
  local url="$1" rest
  case "$url" in
    *://*) rest="${url#*://}"; rest="${rest#*@}"; rest="${rest%%/*}"; echo "${rest%%:*}" ;;
    *@*:*) rest="${url#*@}"; echo "${rest%%:*}" ;;
    [!/.]*:*) [[ "${url%%:*}" != */* ]] && echo "${url%%:*}" ;;
  esac
}

# is_github <url>: the host is github.com, or an SSH host alias that ssh's
# own config resolves to github.com (ssh -G reads the config and connects
# to nothing).
is_github() {
  local host resolved
  host="$(origin_host "$1" | tr '[:upper:]' '[:lower:]')"
  [[ -n "$host" ]] || return 1
  [[ "$host" == "github.com" ]] && return 0
  case "$1" in
    https://*|http://*|git://*) return 1 ;;
  esac
  command -v ssh >/dev/null 2>&1 || return 1
  resolved="$(ssh -G "$host" 2>/dev/null </dev/null | awk 'tolower($1)=="hostname"{print tolower($2); exit}')"
  [[ "$resolved" == "github.com" ]]
}

# origin must be on GitHub.
origin="$(git -C "$root" remote get-url origin 2>/dev/null || true)"
if ! is_github "$origin"; then
  echo "$TAG writing nothing: origin isn't a GitHub URL (${origin:-no origin}); the starter is a GitHub Actions workflow"
  exit 3
fi

# The three versioning fields. field may be "" (a plain-text version file).
missing=0
for f in file field tag; do
  if [[ "$(jq -r --arg f "$f" '(.versioning // {}) | has($f)' "$decl")" != "true" ]]; then
    echo "$TAG versioning.$f missing in .claude/deploy.json"
    missing=1
  fi
done
if [[ $missing -ne 0 ]]; then
  echo "$TAG writing nothing: add the versioning fields above (see the Deploy standard's reference/declaration.md)" >&2
  exit 4
fi
vfile="$(jq -r '.versioning.file' "$decl")"
vfield="$(jq -r '.versioning.field' "$decl")"
vtag="$(jq -r '.versioning.tag' "$decl")"

# Never overwrite.
wf="$root/.github/workflows/release.yml"
sc="$root/.github/scripts/release-tag.sh"
exists=0
for target in "$wf" "$sc"; do
  if [[ -e "$target" ]]; then
    echo "$TAG ${target#"$root"/} already exists; leaving it unchanged"
    exists=1
  fi
done
if [[ $exists -ne 0 ]]; then
  echo "$TAG writing nothing: remove or rename the file above to install the starter" >&2
  exit 5
fi

# sq <value>: the value as a single-quoted shell word.
sq() { printf "'%s'" "${1//\'/\'\\\'\'}"; }

mkdir -p "$(dirname "$wf")" "$(dirname "$sc")"
cp "$TEMPLATES/release.yml" "$wf"
VF="VERSION_FILE=$(sq "$vfile")" VD="VERSION_FIELD=$(sq "$vfield")" VT="TAG_FORMAT=$(sq "$vtag")" \
  awk '
    /^VERSION_FILE=/  { print ENVIRON["VF"]; next }
    /^VERSION_FIELD=/ { print ENVIRON["VD"]; next }
    /^TAG_FORMAT=/    { print ENVIRON["VT"]; next }
    { print }
  ' "$TEMPLATES/release-tag.sh" >"$sc"
chmod +x "$sc"

echo "$TAG wrote .github/workflows/release.yml"
echo "$TAG wrote .github/scripts/release-tag.sh (VERSION_FILE=$vfile, VERSION_FIELD=$vfield, TAG_FORMAT=$vtag)"
exit 0
