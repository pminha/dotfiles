#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="${PLUGIN_DIR:-$SCRIPT_DIR}"

# Refresh the primary usage value without delaying the popup toggle.
"$PLUGIN_DIR/codex.sh" >/dev/null 2>&1 &

# The forecast script owns the popup open/close behavior.
"$PLUGIN_DIR/codex_forecast.sh"
