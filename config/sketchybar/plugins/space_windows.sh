#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/plugins/icon_map.sh"
source "$CONFIG_DIR/plugins/bin.sh"

DEBUG=false
LOG_FILE="$HOME/.local/share/sketchybar/space_windows.log"

log_debug() {
  if [[ "$DEBUG" == true ]]; then
    mkdir -p "${LOG_FILE%/*}"
    echo "$@" >> "$LOG_FILE"
  fi
}

get_workspace_apps() {
  local workspace="$1"

  [[ -z "$workspace" ]] && return 0

  if [[ -n "$JQ_BIN" ]]; then
    "$AEROSPACE_BIN" list-windows --workspace "$workspace" --json 2>/dev/null \
      | "$JQ_BIN" -r '.[] | select(."window-title" != "") | ."app-name"' 2>/dev/null
  else
    "$AEROSPACE_BIN" list-windows --workspace "$workspace" 2>/dev/null \
      | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}'
  fi
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

if [[ "$SENDER" != "aerospace_workspace_change" ]]; then
  exit 0
fi

AEROSPACE_BIN="$(find_command aerospace)"
JQ_BIN="$(find_command jq)"

if [[ -z "$AEROSPACE_BIN" ]]; then
  log_debug "aerospace not found"
  exit 0
fi

current_workspace="${AEROSPACE_FOCUSED_WORKSPACE:-}"
if [[ -z "$current_workspace" ]]; then
  current_workspace="$("$AEROSPACE_BIN" list-workspaces --focused 2>/dev/null)"
fi

if [[ -z "$current_workspace" ]]; then
  log_debug "missing focused workspace"
  exit 0
fi

previous_workspace="${AEROSPACE_PREV_WORKSPACE:-}"
current_apps="$(get_workspace_apps "$current_workspace")"
current_icon_strip="$(build_icon_strip "$current_apps")"

args=(
  --animate sin 5
  --set "space.$current_workspace"
  "label=$current_icon_strip"
  icon.highlight=true
  label.highlight=true
  "background.border_color=$GREY"
)

if [[ -n "$previous_workspace" && "$previous_workspace" != "$current_workspace" ]]; then
  previous_apps="$(get_workspace_apps "$previous_workspace")"
  previous_icon_strip="$(build_icon_strip "$previous_apps")"
  args+=(
    --set "space.$previous_workspace"
    "label=$previous_icon_strip"
    icon.highlight=false
    label.highlight=false
    "background.border_color=$BACKGROUND_2"
  )
fi

sketchybar "${args[@]}"

log_debug "current workspace: $current_workspace"
log_debug "current apps: $current_apps"
log_debug "previous workspace: $previous_workspace"
