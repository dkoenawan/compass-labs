#!/usr/bin/env bash
# lib.sh — shared helpers for the controller scripts (sourced).
CONTROLLER_CONFIG="${TRELLIS_CONTROLLER_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/trellis/controller.json}"
CONTROLLER_STATE="${TRELLIS_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/trellis}"
RUNS_LOG="$CONTROLLER_STATE/runs.jsonl"
cfg() { jq -r "$1 // empty" "$CONTROLLER_CONFIG"; }
now_local() { TZ="$(cfg .timezone)" date -d "${TRELLIS_NOW:-now}" "$1"; }
