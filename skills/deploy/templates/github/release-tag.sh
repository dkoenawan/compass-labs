#!/usr/bin/env bash
# release-tag.sh [--check]
# Tags and publishes a release when a merge into the default branch changes
# the version. Run by .github/workflows/release.yml: on a push to the
# default branch it runs with no argument; on a pull request it runs with
# --check. It can also be run locally with --check.
#
#   (no argument)  Compares the version at HEAD with HEAD^1 (the earlier
#                  default-branch tip, for squash and merge commits alike).
#                  Unchanged: logs "no version change" and exits 0.
#                  Changed and the tag is free: creates the tag on HEAD and
#                  publishes the release in one call
#                  (gh release create {tag} --target {sha} --generate-notes).
#                  The tag already exists: fails, naming it, and leaves the
#                  tag and its release as they are.
#   --check        Prints the tag a merge of HEAD would create, warns if
#                  that tag already exists, and creates nothing.
#
# Needs git, jq (for a JSON version file) and, without --check, gh with
# GH_TOKEN set. The tag is looked up on `origin` with git ls-remote.
#
# This file was copied from a starter and belongs to this repository: edit
# it as you would any of your own scripts. The settings below were filled
# in from the repository's deploy declaration when it was copied.

set -uo pipefail

# --- settings ---------------------------------------------------------------
# VERSION_FILE:  the file that holds the version, relative to the repo root.
# VERSION_FIELD: a jq path to the version in that file (e.g. .version), or
#                empty for a plain-text file holding only the version.
# TAG_FORMAT:    the release tag, with {version} where the version goes.
VERSION_FILE='__VERSION_FILE__'
VERSION_FIELD='__VERSION_FIELD__'
TAG_FORMAT='__TAG_FORMAT__'
# --- end settings -----------------------------------------------------------

die() {
  echo "release-tag: $*" >&2
  exit 1
}

mode="release"
case "${1:-}" in
  "") ;;
  --check) mode="check" ;;
  *) die "unknown argument '$1' (usage: release-tag.sh [--check])" ;;
esac

if [[ "$VERSION_FILE" == __*__ || "$VERSION_FIELD" == __*__ || "$TAG_FORMAT" == __*__ ]]; then
  die "the settings block isn't filled in (VERSION_FILE, VERSION_FIELD, TAG_FORMAT)"
fi
[[ "$TAG_FORMAT" == *"{version}"* ]] || die "TAG_FORMAT '$TAG_FORMAT' has no {version}"

# version_at <rev>: prints the version recorded at <rev>, or nothing when the
# revision or the file isn't there.
version_at() {
  local rev="$1" content
  content="$(git show "$rev:$VERSION_FILE" 2>/dev/null)" || return 0
  if [[ -n "$VERSION_FIELD" ]]; then
    command -v jq >/dev/null 2>&1 || die "jq is needed to read $VERSION_FILE"
    jq -r "$VERSION_FIELD // empty" <<<"$content" 2>/dev/null || die "can't read $VERSION_FIELD from $VERSION_FILE at $rev"
  else
    tr -d '[:space:]' <<<"$content"
  fi
}

# tag_exists <tag>: 0 if origin has it, 1 if not; dies if origin can't be read.
tag_exists() {
  local out status
  out="$(git ls-remote --exit-code --tags origin "refs/tags/$1" 2>&1)"
  status=$?
  case $status in
    0) return 0 ;;
    2) return 1 ;;
    *) die "can't list tags on origin: $out" ;;
  esac
}

sha="$(git rev-parse HEAD 2>/dev/null)" || die "not inside a git repository with a commit"
new="$(version_at HEAD)"
[[ -n "$new" ]] || die "no version found in $VERSION_FILE at HEAD"
tag="${TAG_FORMAT//\{version\}/$new}"

old=""
if git rev-parse -q --verify 'HEAD^1' >/dev/null 2>&1; then
  old="$(version_at 'HEAD^1')"
fi

if [[ "$mode" == "check" ]]; then
  echo "release-tag: would create $tag for version $new at $sha"
  if [[ -n "$old" && "$old" == "$new" ]]; then
    echo "release-tag: note: the version is unchanged from HEAD^1 ($old), so merging this commit creates no tag"
  fi
  if tag_exists "$tag"; then
    echo "release-tag: warning: tag $tag already exists on origin; a merge with this version would fail" >&2
  fi
  exit 0
fi

if [[ -n "$old" && "$old" == "$new" ]]; then
  echo "release-tag: no version change ($new): no tag or release created"
  exit 0
fi

if tag_exists "$tag"; then
  die "tag $tag already exists on origin; leaving it and its release unchanged (version ${old:-none} -> $new at $sha)"
fi

command -v gh >/dev/null 2>&1 || die "gh is needed to publish the release"
gh release create "$tag" --target "$sha" --generate-notes \
  || die "gh release create $tag failed; no tag was moved"
echo "release-tag: created $tag at $sha and published its release (version ${old:-none} -> $new)"
exit 0
