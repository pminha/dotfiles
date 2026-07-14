#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCAL_WEATHER_CONFIG="$SCRIPT_DIR/weather.local.sh"

. "$SCRIPT_DIR/bin.sh"

[ -f "$LOCAL_WEATHER_CONFIG" ] && . "$LOCAL_WEATHER_CONFIG"

WEATHER_LOCATION="${WEATHER_LOCATION:-}"
WEATHER_REGION="${WEATHER_REGION:-}"
WEATHER_LANG="${WEATHER_LANG:-en}"

if [ -z "$WEATHER_LOCATION" ]; then
  sketchybar --set "$NAME" label="Weather"
  exit 0
fi

sketchybar --set "$NAME" \
  label="Loading..." \
  icon.color=0xff5edaff

JQ_BIN="$(find_command jq)"
if [[ -z "$JQ_BIN" ]]; then
  sketchybar --set "$NAME" label="$WEATHER_LOCATION"
  exit 0
fi

# Line below replaces spaces with +
LOCATION_ESCAPED="${WEATHER_LOCATION// /+}+${WEATHER_REGION// /+}"
WEATHER_JSON="$(curl --fail --silent --max-time 4 "https://wttr.in/$LOCATION_ESCAPED?0pq&format=j1&lang=$WEATHER_LANG" 2>/dev/null)"

# Fallback if empty
if [ -z "$WEATHER_JSON" ]; then
  sketchybar --set "$NAME" label="$WEATHER_LOCATION"
  exit 0
fi

TEMPERATURE="$(printf '%s' "$WEATHER_JSON" | "$JQ_BIN" -r '.current_condition[0].temp_C // empty')"
WEATHER_DESCRIPTION="$(printf '%s' "$WEATHER_JSON" | "$JQ_BIN" -r '.current_condition[0].weatherDesc[0].value // empty')"

if [[ -z "$TEMPERATURE" || -z "$WEATHER_DESCRIPTION" ]]; then
  sketchybar --set "$NAME" label="$WEATHER_LOCATION"
  exit 0
fi

if (( ${#WEATHER_DESCRIPTION} > 16 )); then
  WEATHER_DESCRIPTION="${WEATHER_DESCRIPTION:0:16}..."
fi

sketchybar --set "$NAME" \
  label="${TEMPERATURE}°C • $WEATHER_DESCRIPTION"
