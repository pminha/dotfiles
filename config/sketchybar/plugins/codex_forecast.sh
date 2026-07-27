#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="${PLUGIN_DIR:-$SCRIPT_DIR}"
CONFIG_DIR="${CONFIG_DIR:-$(cd -- "$PLUGIN_DIR/.." && pwd)}"

source "$CONFIG_DIR/colors.sh"
source "$PLUGIN_DIR/bin.sh"
source "$PLUGIN_DIR/icon_map.sh"

icon_map "Codex"
CODEX_ICON="$icon_result"

SKETCHYBAR_BIN="$(find_command sketchybar || true)"
CURL_BIN="$(find_command curl || true)"
JQ_BIN="$(find_command jq || true)"

set_forecast_label() {
  local label="$1"
  local color="${2:-$GREY}"

  [[ -n "$SKETCHYBAR_BIN" ]] || return 0
  "$SKETCHYBAR_BIN" --set codex.forecast \
    icon="$CODEX_ICON" \
    icon.font="sketchybar-app-font:Regular:14.0" \
    icon.color="$color" \
    label="$label" \
    label.color="$color"
}

if [[ -z "$SKETCHYBAR_BIN" || -z "$CURL_BIN" || -z "$JQ_BIN" ]]; then
  set_forecast_label "Forecast unavailable"
  exit 0
fi

POPUP_STATE="$(
  "$SKETCHYBAR_BIN" --query codex 2>/dev/null |
    "$JQ_BIN" -r '.popup.drawing // "off"' 2>/dev/null
)"

if [[ "$POPUP_STATE" == "on" ]]; then
  "$SKETCHYBAR_BIN" --set codex popup.drawing=off
  exit 0
fi

set_forecast_label "Loading forecast..."
"$SKETCHYBAR_BIN" --set codex popup.drawing=on

FORECAST_JSON="$(
  "$CURL_BIN" --fail --silent --show-error --max-time 8 \
    -H 'Accept: application/json' \
    'https://www.willcodexquotareset.com/api/forecast' 2>/dev/null
)"

SCORE="$(
  printf '%s\n' "$FORECAST_JSON" |
    "$JQ_BIN" -er '
      .forecast.score
      | numbers
      | select(. >= 0 and . <= 100)
      | tostring
    ' 2>/dev/null
)"

if [[ -z "$SCORE" ]]; then
  set_forecast_label "Forecast unavailable"
  exit 0
fi

set_forecast_label "${SCORE}% • reset within next 48h" "$LABEL_COLOR"
