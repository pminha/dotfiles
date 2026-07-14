#!/usr/bin/env bash

WIDTH=100

source "$CONFIG_DIR/plugins/bin.sh"

JQ_BIN="$(find_command jq)"

is_int() {
  [[ "$1" =~ ^[0-9]+$ ]]
}

query_slider_value() {
  local field="$1"
  local value

  [[ -z "$JQ_BIN" ]] && return 1

  value="$(sketchybar --query "$NAME" 2>/dev/null | "$JQ_BIN" -r ".slider.$field // empty" 2>/dev/null)"
  is_int "$value" || return 1

  printf '%s' "$value"
}

volume_change() {
  is_int "$INFO" || exit 0

  source "$CONFIG_DIR/icons.sh"
  case $INFO in
    [6-9][0-9]|100) ICON=$VOLUME_100
    ;;
    [3-5][0-9]) ICON=$VOLUME_66
    ;;
    [1-2][0-9]) ICON=$VOLUME_33
    ;;
    [1-9]) ICON=$VOLUME_10
    ;;
    0) ICON=$VOLUME_0
    ;;
    *) ICON=$VOLUME_100
  esac

  sketchybar --set volume_icon "label=$ICON" \
             --set "$NAME" "slider.percentage=$INFO"

  INITIAL_WIDTH="$(query_slider_value width)"
  if [[ "$INITIAL_WIDTH" == "0" ]]; then
    sketchybar --animate tanh 30 --set "$NAME" "slider.width=$WIDTH"
  fi

  sleep 2

  # Check wether the volume was changed another time while sleeping
  FINAL_PERCENTAGE="$(query_slider_value percentage)"
  if [[ "$FINAL_PERCENTAGE" == "$INFO" ]]; then
    sketchybar --animate tanh 30 --set "$NAME" slider.width=0
  fi
}

mouse_clicked() {
  osascript -e "set volume output volume $PERCENTAGE"
}

case "$SENDER" in
  "volume_change") volume_change
  ;;
  "mouse.clicked") mouse_clicked
  ;;
esac
