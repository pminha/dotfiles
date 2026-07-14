#!/usr/bin/env bash

lookup_pair_value() {
  local key="$1"
  local pairs="$2"
  local left right rest

  while read -r left right rest; do
    if [[ "$left" == "$key" ]]; then
      printf '%s' "$right"
      return 0
    fi
  done <<< "$pairs"

  return 1
}

build_nsscreen_to_direct_display_map() {
  local swift_bin="$1"

  [[ -z "$swift_bin" ]] && return 1

  TMPDIR="${TMPDIR:-/tmp}" "$swift_bin" -e '
import AppKit

for (index, screen) in NSScreen.screens.enumerated() {
  if let displayID = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber {
    let directID = displayID.intValue
    print("\(index) \(directID)")
    print("\(index + 1) \(directID)")
    print("-\(index + 1) \(directID)")
  }
}
' 2>/dev/null
}

build_direct_to_sketchybar_display_map() {
  local jq_bin="$1"

  [[ -z "$jq_bin" ]] && return 1

  sketchybar --query displays 2>/dev/null \
    | "$jq_bin" -r '.[] | select(.DirectDisplayID and .["arrangement-id"]) | "\(.DirectDisplayID) \(.["arrangement-id"])"' 2>/dev/null
}

build_aerospace_display_map() {
  local aerospace_bin="$1"
  local jq_bin="$2"
  local swift_bin="$3"
  local monitor_map nsscreen_to_direct direct_to_sketchybar
  local as_monitor nsscreen_id rest direct_id display_id

  AEROSPACE_DISPLAY_MAP=()

  [[ -z "$aerospace_bin" ]] && return 1

  monitor_map="$("$aerospace_bin" list-monitors --format '%{monitor-id} %{monitor-appkit-nsscreen-screens-id}' 2>/dev/null)" || true
  [[ -z "$monitor_map" ]] && return 1

  direct_to_sketchybar="$(build_direct_to_sketchybar_display_map "$jq_bin")" || true
  nsscreen_to_direct="$(build_nsscreen_to_direct_display_map "$swift_bin")" || true

  if [[ -n "$direct_to_sketchybar" && -n "$nsscreen_to_direct" ]]; then
    while read -r as_monitor nsscreen_id rest; do
      [[ -z "$as_monitor" || -z "$nsscreen_id" ]] && continue

      direct_id="$(lookup_pair_value "$nsscreen_id" "$nsscreen_to_direct")"
      display_id="$(lookup_pair_value "$direct_id" "$direct_to_sketchybar")"

      if [[ -n "$display_id" ]]; then
        AEROSPACE_DISPLAY_MAP+=("$as_monitor" "$display_id")
      fi
    done <<< "$monitor_map"
  fi

  if [[ "${#AEROSPACE_DISPLAY_MAP[@]}" -eq 0 ]]; then
    AEROSPACE_DISPLAY_MAP=( $monitor_map )
  fi

  [[ "${#AEROSPACE_DISPLAY_MAP[@]}" -gt 0 ]]
}

display_for_aerospace_monitor() {
  local monitor="$1"
  local i

  for ((i=0; i<${#AEROSPACE_DISPLAY_MAP[@]}; i+=2)); do
    if [[ "${AEROSPACE_DISPLAY_MAP[i]}" == "$monitor" ]]; then
      printf '%s' "${AEROSPACE_DISPLAY_MAP[i+1]}"
      return 0
    fi
  done

  printf '%s' "$monitor"
}
