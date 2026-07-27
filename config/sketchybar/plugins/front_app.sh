#!/usr/bin/env bash

source "$CONFIG_DIR/plugins/icon_map.sh"
source "$CONFIG_DIR/plugins/bin.sh"

build_icon_strip() {
  local apps="$1"
  local app
  local icon_strip=""

  while IFS= read -r app; do
    [[ -z "$app" ]] && continue
    icon_map "$app"
    icon_strip+=" $icon_result"
  done <<< "$apps"

  printf '%s' "$icon_strip"
}

if [[ "$SENDER" != "front_app_switched" ]]; then
  exit 0
fi

sketchybar --set "$NAME" label="$INFO"

AEROSPACE_BIN="$(find_command aerospace)"
JQ_BIN="$(find_command jq)"

if [[ -z "$AEROSPACE_BIN" ]]; then
  exit 0
fi

focused_workspace="$("$AEROSPACE_BIN" list-workspaces --focused 2>/dev/null)"
if [[ -z "$focused_workspace" ]]; then
  exit 0
fi

if [[ -n "$JQ_BIN" ]]; then
  apps="$("$AEROSPACE_BIN" list-windows --workspace "$focused_workspace" --json 2>/dev/null \
    | "$JQ_BIN" -r '.[] | select(."window-title" != "") | ."app-name"' 2>/dev/null)"
else
  apps="$("$AEROSPACE_BIN" list-windows --workspace "$focused_workspace" 2>/dev/null \
    | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')"
fi

sketchybar --set "space.$focused_workspace" label="$(build_icon_strip "$apps")"
