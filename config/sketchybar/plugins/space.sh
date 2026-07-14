#!/usr/bin/env bash

source "$CONFIG_DIR/plugins/bin.sh"

AEROSPACE_BIN="$(find_command aerospace)"

update() {
  # Only handle space_change events, let space_windows.sh handle aerospace_workspace_change
  if [ "$SENDER" = "space_change" ]; then
    [[ -z "$AEROSPACE_BIN" ]] && return 0

    source "$CONFIG_DIR/colors.sh"
    
    # Get current focused workspace
    CURRENT_FOCUSED=$("$AEROSPACE_BIN" list-workspaces --focused 2>/dev/null)
    [[ -z "$CURRENT_FOCUSED" ]] && return 0
    
    # Set the focused space to highlighted state
    sketchybar --set space.$CURRENT_FOCUSED icon.highlight=true \
                      label.highlight=true \
                      background.border_color=$GREY
  fi
}

set_space_label() {
  sketchybar --set $NAME icon="$@"
}

mouse_clicked() {
  if [ "$BUTTON" = "right" ]; then
    echo ''
  else
    if [ "$MODIFIER" = "shift" ]; then
      SPACE_LABEL="$(osascript -e "return (text returned of (display dialog \"Give a name to space $NAME:\" default answer \"\" with icon note buttons {\"Cancel\", \"Continue\"} default button \"Continue\"))")"
      if [ $? -eq 0 ]; then
        if [ "$SPACE_LABEL" = "" ]; then
          set_space_label "${NAME:6}"
        else
          set_space_label "${NAME:6} ($SPACE_LABEL)"
        fi
      fi
    else
      [[ -n "$AEROSPACE_BIN" ]] && "$AEROSPACE_BIN" workspace "${NAME#*.}"
    fi
  fi
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
  ;;
  *) update
  ;;
esac
