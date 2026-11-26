#!/usr/bin/env bash
# install-schedule.sh [--env-file FILE]
# Adds one hourly crontab line that runs run.sh; run.sh itself decides
# whether this hour is a configured local slot, so no time-zone conversion
# is needed here. CLAUDE_BIN and GH_BIN are pinned to the binaries found now
# (cron's PATH is minimal). --env-file sources a file first, for example one
# exporting CLAUDE_CODE_OAUTH_TOKEN for unattended auth. Refuses a second
# install; the line ends with "# trellis:controller".
set -euo pipefail
SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CRONTAB="${CRONTAB_BIN:-crontab}"
env_file=""
[[ "${1:-}" == "--env-file" ]] && env_file="${2:?--env-file needs a path}"
source "$SCRIPTS/lib.sh"
[[ -f "$CONTROLLER_CONFIG" ]] || { echo "install-schedule: no config at $CONTROLLER_CONFIG" >&2; exit 1; }
current="$("$CRONTAB" -l 2>/dev/null || true)"
grep -q '# trellis:controller$' <<<"$current" && { echo "install-schedule: already installed" >&2; exit 1; }
claude_bin="${CLAUDE_BIN:-$(command -v claude || true)}"; gh_bin="${GH_BIN:-$(command -v gh || true)}"
[[ -n "$claude_bin" && -n "$gh_bin" ]] || { echo "install-schedule: claude and gh must be on PATH" >&2; exit 1; }
prefix=""
[[ -n "$env_file" ]] && prefix="[ -r '$env_file' ] && . '$env_file'; "
line="0 * * * * ${prefix}TRELLIS_CONTROLLER_CONFIG='$CONTROLLER_CONFIG' CLAUDE_BIN='$claude_bin' GH_BIN='$gh_bin' /bin/bash '$SCRIPTS/run.sh' >> '$CONTROLLER_STATE/cron.log' 2>&1 # trellis:controller"
mkdir -p "$CONTROLLER_STATE"
{ [[ -n "$current" ]] && printf '%s\n' "$current"; printf '%s\n' "$line"; } | "$CRONTAB" -
echo "install-schedule: installed (hourly; acts in slots $(jq -c .slots "$CONTROLLER_CONFIG") $(jq -r .timezone "$CONTROLLER_CONFIG"))"
