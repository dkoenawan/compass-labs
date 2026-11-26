#!/usr/bin/env bash
# lib.sh — shared helpers for the controller scripts (sourced).
CONTROLLER_CONFIG="${COMPASS_CONTROLLER_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/compass/controller.json}"
CONTROLLER_STATE="${COMPASS_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/compass}"
RUNS_LOG="$CONTROLLER_STATE/runs.jsonl"
cfg() { jq -r "$1 // empty" "$CONTROLLER_CONFIG"; }
now_local() { TZ="$(cfg .timezone)" date -d "${COMPASS_NOW:-now}" "$1"; }
