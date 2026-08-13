#!/usr/bin/env bash

source "$PLUGIN_DIR/icon_map.sh"
icon_map "Codex"
CODEX_ICON="$icon_result"

codex_usage=(
  drawing=on
  icon="$CODEX_ICON"
  icon.font="sketchybar-app-font:Regular:14.0"
  icon.drawing=on
  icon.color="$GREY"
  label="—"
  label.drawing=on
  label.color="$GREY"
  script="$PLUGIN_DIR/codex.sh"
  update_freq=300
  click_script="$PLUGIN_DIR/codex_click.sh"
  popup.height=24
  popup.background.color=0xff1e1e2e
  popup.background.border_color=0xff1e1e2e
  popup.background.border_width=2
  popup.background.corner_radius=9
  popup.background.padding_left=12
  popup.background.padding_right=12
  popup.background.shadow.drawing=on
)

codex_forecast=(
  width=270
  icon="$CODEX_ICON"
  icon.font="sketchybar-app-font:Regular:14.0"
  icon.color="$GREY"
  label="Forecast unavailable"
  label.color="$GREY"
)

codex_forecast_source=(
  icon.drawing=off
  label="https://www.willcodexquotareset.com/"
  label.font="$FONT:Regular:9.0"
  label.align=left
  label.color="$GREY"
  label.padding_left=0
  label.padding_right=0
)

sketchybar --add item codex right \
           --set codex "${codex_usage[@]}" \
           --add item codex.forecast popup.codex \
           --set codex.forecast "${codex_forecast[@]}" \
           --add item codex.forecast.source popup.codex \
           --set codex.forecast.source "${codex_forecast_source[@]}" \
           --subscribe codex system_woke
