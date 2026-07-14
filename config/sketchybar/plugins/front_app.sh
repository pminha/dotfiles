#!/usr/bin/env bash

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

source "$CONFIG_DIR/plugins/icon_map.sh"
source "$CONFIG_DIR/plugins/bin.sh"

build_icon_strip() {
  local apps="$1"
  local app
  local icon_strip=" "

  if [[ -n "$apps" ]]; then
    while IFS= read -r app; do
      [[ -z "$app" ]] && continue
      icon_map "$app"
      icon_strip+=" $icon_result"
    done <<< "$apps"
  else
    icon_strip=" —"
  fi

  printf '%s' "$icon_strip"
}

if [ "$SENDER" = "front_app_switched" ]; then
  #echo name:$NAME INFO: $INFO SENDER: $SENDER, SID: $SID >> ~/aaaa
  AEROSPACE_BIN="$(find_command aerospace)"
  JQ_BIN="$(find_command jq)"

  if [[ -z "$AEROSPACE_BIN" || -z "$JQ_BIN" ]]; then
    sketchybar --set "$NAME" label="$INFO" icon.background.image="app.$INFO" icon.background.image.scale=0.8
    exit 0
  fi

  focused_workspace="$("${AEROSPACE_BIN}" list-workspaces --focused 2>/dev/null)"
  if [[ -z "$focused_workspace" || "$focused_workspace" == *$'\n'* ]]; then
    sketchybar --set "$NAME" label="$INFO" icon.background.image="app.$INFO" icon.background.image.scale=0.8
    exit 0
  fi

  apps="$("${AEROSPACE_BIN}" list-windows --workspace "$focused_workspace" --json 2>/dev/null | "${JQ_BIN}" -r '.[] | select(."window-title" != "") | ."app-name"' 2>/dev/null)"
  icon_strip="$(build_icon_strip "$apps")"

  sketchybar --set "$NAME" label="$INFO" icon.background.image="app.$INFO" icon.background.image.scale=0.8 \
             --set "space.$focused_workspace" label="$icon_strip"
fi
