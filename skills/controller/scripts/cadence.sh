#!/usr/bin/env bash
# cadence.sh [YYYY-MM-DD]
# Prints "compass" in the last 7 days of the month (the trellis week) and
# "side" otherwise (weeks 1-3, side-project work). Default: today.
set -euo pipefail
d="${1:-$(date +%F)}"
day=$(date -d "$d" +%-d)
last=$(date -d "$(date -d "$d" +%Y-%m-01) +1 month -1 day" +%-d)
if (( day > last - 7 )); then echo compass; else echo side; fi
