#!/usr/bin/env bash
# uninstall-schedule.sh — removes the "# trellis:controller" crontab line; leaves every other line.
set -euo pipefail
CRONTAB="${CRONTAB_BIN:-crontab}"
current="$("$CRONTAB" -l 2>/dev/null || true)"
grep -q '# trellis:controller$' <<<"$current" || { echo "uninstall-schedule: not installed"; exit 0; }
grep -v '# trellis:controller$' <<<"$current" | "$CRONTAB" -
echo "uninstall-schedule: removed"
