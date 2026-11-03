#!/usr/bin/env bash
# Fixture deploy step. Harmless: it appends what it was asked to do to
# ./deploy-log in the fixture copy and prints it. Nothing leaves the folder.
log="$(dirname "$0")/deploy-log"
case "${1:-}" in
  --check-targets) echo "targets ok" ;;
  *) echo "deployed ${1:-nothing}${2:+ $2}" | tee -a "$log" ;;
esac
