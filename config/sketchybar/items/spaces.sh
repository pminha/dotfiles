#!/usr/bin/env bash

#SPACE_ICONS=("1" "2" "3" "4")

# Destroy space on right click, focus space on left click.
# New space by left clicking separator (>)

sketchybar --add event aerospace_workspace_change
#echo $(aerospace list-workspaces --monitor 1 --visible no --empty no) >> ~/aaaa

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

add_space_item() {
  local sid="$1"
  local icon_strip="$2"

  space=(
    space="$sid"
    icon="$sid"
    icon.highlight_color=$WHITE
    icon.padding_left=10
    icon.padding_right=10
    ignore_association=on
    padding_left=2
    padding_right=2
    label.padding_right=20
    label.color=$GREY
    label.highlight_color=$WHITE
    label="$icon_strip"
    label.font="sketchybar-app-font:Regular:16.0"
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
    icon.font="$FONT:Heavy:16.0"
    padding_left=10
    padding_right=8
    label.drawing=off
    ignore_association=on
    script="$PLUGIN_DIR/space_windows.sh"
    icon.color=$WHITE
  )

  sketchybar --add item space_creator left               \
             --set space_creator "${space_creator[@]}"   \
             --subscribe space_creator aerospace_workspace_change
}

add_fallback_spaces() {
  local sid

  for sid in 1 2 3 4 5 6 7 8 9 10; do
    add_space_item "$sid" " —"
  done
}

if [[ -z "$AEROSPACE_BIN" ]]; then
  add_fallback_spaces
  add_space_creator
  return 0 2>/dev/null || exit 0
fi

workspaces="$("${AEROSPACE_BIN}" list-workspaces --all 2>/dev/null | sort_workspaces)"
if [[ -z "$workspaces" ]]; then
  add_fallback_spaces
  add_space_creator
  return 0 2>/dev/null || exit 0
fi

for sid in $workspaces; do
  apps=$("${AEROSPACE_BIN}" list-windows --workspace "$sid" 2>/dev/null | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')
  icon_strip="$(build_icon_strip "$apps")"
  add_space_item "$sid" "$icon_strip"
done

add_space_creator

# sketchybar  --add item change_windows left \
#             --set change_windows script="$PLUGIN_DIR/change_windows.sh" \
#             --subscribe change_windows space_changes
