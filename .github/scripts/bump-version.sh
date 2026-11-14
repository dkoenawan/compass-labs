#!/usr/bin/env bash
# bump-version.sh <patch|minor|major>
# compass-labs' version bump (#30 DES-010): sets .claude-plugin/plugin.json's
# "version" to the next patch, minor or major version and prints the new
# version. It doesn't commit: the commit is its own declared step in
# .claude/deploy.json. Only the version line changes; the rest of the file
# is left as it is. A bad level, or a version that isn't MAJOR.MINOR.PATCH,
# exits 1 and changes nothing.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_JSON="$SCRIPT_DIR/../../.claude-plugin/plugin.json"

die() {
  echo "bump-version: $*" >&2
  exit 1
}

level="${1:-}"
case "$level" in
  patch|minor|major) ;;
  *) die "level must be patch, minor or major (got '${level}')" ;;
esac

[[ -f "$PLUGIN_JSON" ]] || die "plugin.json not found at $PLUGIN_JSON"
command -v jq >/dev/null 2>&1 || die "jq is needed"

current="$(jq -r '.version // empty' "$PLUGIN_JSON" 2>/dev/null)" || die "plugin.json isn't valid JSON"
[[ "$current" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]] || die "current version '$current' isn't MAJOR.MINOR.PATCH"
major="${BASH_REMATCH[1]}" minor="${BASH_REMATCH[2]}" patch="${BASH_REMATCH[3]}"

case "$level" in
  major) major=$((major + 1)); minor=0; patch=0 ;;
  minor) minor=$((minor + 1)); patch=0 ;;
  patch) patch=$((patch + 1)) ;;
esac
next="$major.$minor.$patch"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
sed -E "s/(\"version\"[[:space:]]*:[[:space:]]*\")$current(\")/\1$next\2/" "$PLUGIN_JSON" >"$tmp"
[[ "$(jq -r '.version' "$tmp" 2>/dev/null)" == "$next" ]] || die "couldn't set the version in plugin.json"
cat "$tmp" >"$PLUGIN_JSON"

echo "$next"
