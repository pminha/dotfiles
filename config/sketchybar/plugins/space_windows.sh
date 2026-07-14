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

get_ms_time() {
  local time_bin

  time_bin="$(find_command gdate)"
  if [[ -n "$time_bin" ]]; then
    echo $(( $("$time_bin" +%s%N) / 1000000 ))
  else
    echo $(( $(date +%s000000000) / 1000000 ))
  fi
}

time_start() {
  if [[ "$DEBUG" == true ]]; then
    TIME_BEGIN="$(get_ms_time)"
    log_debug "---------------------------------"
  fi
}

time_checkpoint() {
  if [[ "$DEBUG" == true ]]; then
    local current_time
    current_time="$(get_ms_time)"
    log_debug "Checkpoint [$1]: $((current_time - TIME_BEGIN)) ms"
  fi
}

time_end() {
  if [[ "$DEBUG" == true ]]; then
    local end_time
    end_time="$(get_ms_time)"
    log_debug "Elapsed time end: $((end_time - TIME_BEGIN)) ms"
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

  ICON_STRIP=" "
  if [[ -n "$apps" ]]; then
    while IFS= read -r app; do
      [[ -z "$app" ]] && continue
      icon_map "$app"
      ICON_STRIP+=" $icon_result"
    done <<< "$apps"
  else
    ICON_STRIP=" —"
  fi
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
previous_workspace="${AEROSPACE_PREV_WORKSPACE:-}"

if [[ -z "$current_workspace" ]]; then
  log_debug "missing focused workspace"
  exit 0
fi

time_start

time_checkpoint "before aerospace query"
current_apps="$(get_workspace_apps "$current_workspace")"
build_icon_strip "$current_apps"
current_icon_strip="$ICON_STRIP"

previous_apps=""
previous_icon_strip=" —"
if [[ -n "$previous_workspace" && "$previous_workspace" != "$current_workspace" ]]; then
  previous_apps="$(get_workspace_apps "$previous_workspace")"
  build_icon_strip "$previous_apps"
  previous_icon_strip="$ICON_STRIP"
fi

time_checkpoint "after aerospace query"

# Do not update display placement here. Space items are assigned to displays
# during startup in items/spaces.sh; changing display on focus events moves
# workspaces between monitors and breaks multi-monitor bars.
args=(
  --animate sin 5
  --set "space.$current_workspace"
  "label=$current_icon_strip"
  icon.highlight=true
  label.highlight=true
  "background.border_color=$GREY"
)

if [[ -n "$previous_workspace" && "$previous_workspace" != "$current_workspace" ]]; then
  args+=(
    --set "space.$previous_workspace"
    "label=$previous_icon_strip"
    icon.highlight=false
    label.highlight=false
    "background.border_color=$BACKGROUND_2"
  )
fi

sketchybar "${args[@]}"
time_checkpoint "after sketchybar update"

log_debug "current workspace: $current_workspace"
log_debug "current apps: $current_apps"
log_debug "previous workspace: $previous_workspace"
log_debug "previous apps: $previous_apps"

time_end
