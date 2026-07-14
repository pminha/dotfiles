#!/usr/bin/env bash

wifi=(
  script="$PLUGIN_DIR/wifi.sh"
  update_freq=60
  updates=on
  icon.font="$FONT:Regular:14.0"
  label.font="$FONT:Regular:12.0"
)

sketchybar --add item wifi right \
           --set wifi "${wifi[@]}" \
           --subscribe wifi system_woke
