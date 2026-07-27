#!/usr/bin/env bash

# Destroy space on right click, focus space on left click.

sketchybar --add event aerospace_workspace_change

source "$PLUGIN_DIR/icon_map.sh"
source "$PLUGIN_DIR/bin.sh"

AEROSPACE_BIN="$(find_command aerospace)"

sort_workspaces() {
  awk '
    /^[0-9]+$/ { printf "0 %010d %s\n", $1, $0; next }
    { printf "1 %s %s\n", $0, $0 }
  ' | sort | cut -d' ' -f3-
}

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

add_space_item() {
  local sid="$1"
  local icon_strip="$2"

  space=(
    space="$sid"
    icon="$sid"
    icon.font="$FONT:Regular:13.0"
    icon.color=$GREY
    icon.highlight_color=$WHITE
    icon.padding_left=6
    icon.padding_right=6
    ignore_association=on
    padding_left=1
    padding_right=1
    label="$icon_strip"
    label.drawing=on
    label.font="sketchybar-app-font:Regular:14.0"
    label.color=$GREY
    label.highlight_color=$WHITE
    label.padding_left=0
    label.padding_right=10
    label.y_offset=-1
    background.color=$BACKGROUND_1
    background.border_color=$BACKGROUND_2
    script="$PLUGIN_DIR/space.sh"
  )

  sketchybar --add space "space.$sid" left \
             --set "space.$sid" "${space[@]}" \
             --subscribe "space.$sid" mouse.clicked
}

add_space_creator() {
  space_creator=(
    icon=􀆊
    icon.font="$FONT:Heavy:14.0"
    padding_left=6
    padding_right=6
    label.drawing=off
    ignore_association=on
    script="$PLUGIN_DIR/space_windows.sh"
    icon.color=$WHITE
  )

  sketchybar --add item space_creator left \
             --set space_creator "${space_creator[@]}" \
             --subscribe space_creator aerospace_workspace_change
}

add_fallback_spaces() {
  local sid

  for sid in 1 2 3 4 5 6 7 8 9 10; do
    add_space_item "$sid" ""
  done
}

if [[ -z "$AEROSPACE_BIN" ]]; then
  add_fallback_spaces
  add_space_creator
  return 0 2>/dev/null || exit 0
fi

workspaces="$("$AEROSPACE_BIN" list-workspaces --all 2>/dev/null | sort_workspaces)"
if [[ -z "$workspaces" ]]; then
  add_fallback_spaces
  add_space_creator
  return 0 2>/dev/null || exit 0
fi

for sid in $workspaces; do
  apps="$("$AEROSPACE_BIN" list-windows --workspace "$sid" 2>/dev/null | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')"
  add_space_item "$sid" "$(build_icon_strip "$apps")"
done

add_space_creator
