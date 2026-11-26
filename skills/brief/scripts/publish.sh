#!/usr/bin/env bash
# publish.sh <brief.md> [YYYY-MM-DD]
# Publishes the brief as one issue "Trellis brief YYYY-MM-DD" (label
# trellis-brief, created if missing) in brief_repo, then closes earlier open
# briefs. Its only GitHub writes. Refuses a body over 65,000 characters.
set -euo pipefail
SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPTS/../../controller/scripts/lib.sh"
GH="${GH_BIN:-gh}"
file="${1:?Usage: publish.sh <brief.md> [date]}"; date="${2:-$(now_local +%F)}"
(( $(wc -c < "$file") <= 65000 )) || { echo "publish: brief too long" >&2; exit 1; }
cd "$(cfg .brief_repo)"
"$GH" label create trellis-brief --color 1f6f8b --description "Weekly Trellis brief" >/dev/null 2>&1 || true
old="$("$GH" issue list --label trellis-brief --state open --json number -q '.[].number')"
url="$("$GH" issue create --title "Trellis brief $date" --label trellis-brief --body-file "$file")"
for n in $old; do "$GH" issue close "$n" --comment "Superseded by $url" >/dev/null; done
echo "$url"
