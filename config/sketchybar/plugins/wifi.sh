#!/bin/sh

AIRPORT="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"
SSID=""

if [ -x "$AIRPORT" ]; then
  SSID=$("$AIRPORT" -I | awk -F: '($1 ~ "^ *SSID$"){print $2}' | cut -c 2-)
else
  for interface in en0 en1; do
    SSID=$(networksetup -getairportnetwork "$interface" 2>/dev/null | sed 's/^Current Wi-Fi Network: //')
    case "$SSID" in
      "" | *"not a Wi-Fi interface"* | *"not associated"*)
        SSID=""
        ;;
      *)
        break
        ;;
    esac
  done
fi

if [ -z "$SSID" ]; then
  SSID="Off"
fi

sketchybar --set wifi \
  icon= icon.color=0xff58d1fc \
  label="$SSID"
