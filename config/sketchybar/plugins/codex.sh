#!/usr/bin/env bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="${PLUGIN_DIR:-$SCRIPT_DIR}"
CONFIG_DIR="${CONFIG_DIR:-$(cd -- "$PLUGIN_DIR/.." && pwd)}"

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"
source "$PLUGIN_DIR/bin.sh"
source "$PLUGIN_DIR/icon_map.sh"

icon_map "Codex"
CODEX_ICON="$icon_result"

SKETCHYBAR_BIN="$(find_command sketchybar || true)"
CODEX_BIN="$(find_command codex || true)"
JQ_BIN="$(find_command jq || true)"
PERL_BIN="$(find_command perl || true)"

set_unavailable() {
  [[ -n "$SKETCHYBAR_BIN" ]] || return 0
  "$SKETCHYBAR_BIN" --set "${NAME:-codex}" \
    icon="$CODEX_ICON" \
    icon.font="sketchybar-app-font:Regular:14.0" \
    icon.color="$GREY" \
    label="—" \
    label.color="$GREY"
}

if [[ -z "$SKETCHYBAR_BIN" || -z "$CODEX_BIN" || -z "$JQ_BIN" || -z "$PERL_BIN" ]]; then
  set_unavailable
  exit 0
fi

REQUESTS=$'{"id":1,"method":"initialize","params":{"clientInfo":{"name":"sketchybar-codex-usage","version":"1.0"}}}\n{"id":2,"method":"account/rateLimits/read"}'

# Keep a slow or unavailable app-server from blocking SketchyBar updates.
SERVER_OUTPUT="$(
  {
    printf '%s\n' "$REQUESTS"
    sleep 2
  } |
    "$PERL_BIN" -e 'alarm 8; exec @ARGV' "$CODEX_BIN" app-server --listen stdio:// 2>/dev/null
)"

RATE_LIMIT_RESULT="$(
  printf '%s\n' "$SERVER_OUTPUT" |
    "$JQ_BIN" -cer 'select(.id == 2 and .result != null) | .result' 2>/dev/null |
    tail -n 1
)"

if [[ -z "$RATE_LIMIT_RESULT" ]]; then
  set_unavailable
  exit 0
fi

USAGE_AND_RESET="$(
  printf '%s\n' "$RATE_LIMIT_RESULT" |
    "$JQ_BIN" -er '
      (.rateLimitsByLimitId.codex.primary // .rateLimits.primary // empty)
      | select(.usedPercent != null and .resetsAt != null)
      | "\(.usedPercent)\t\(.resetsAt)"
    ' 2>/dev/null
)"

if [[ -z "$USAGE_AND_RESET" ]]; then
  set_unavailable
  exit 0
fi

IFS=$'\t' read -r USED_PERCENT RESET_AT <<<"$USAGE_AND_RESET"

if [[ ! "$USED_PERCENT" =~ ^[0-9]+$ || ! "$RESET_AT" =~ ^[0-9]+$ ]]; then
  set_unavailable
  exit 0
fi

REMAINING_PERCENT=$((100 - USED_PERCENT))

SECONDS_UNTIL_RESET=$((RESET_AT - $(date +%s)))

if (( SECONDS_UNTIL_RESET > 86400 )); then
  UPDATE_FREQ=300
  DAYS=$((SECONDS_UNTIL_RESET / 86400))
  HOURS=$(((SECONDS_UNTIL_RESET % 86400) / 3600))
  COUNTDOWN="${DAYS}d $(printf '%02dh' "$HOURS")"
else
  UPDATE_FREQ=60
  HOURS=$((SECONDS_UNTIL_RESET / 3600))
  MINUTES=$(((SECONDS_UNTIL_RESET % 3600) / 60))
  if (( HOURS < 0 )); then
    HOURS=0
  fi
  if (( MINUTES < 0 )); then
    MINUTES=0
  fi
  COUNTDOWN="$(printf '%02dh %02dm' "$HOURS" "$MINUTES")"
fi

"$SKETCHYBAR_BIN" --set "${NAME:-codex}" \
  update_freq="$UPDATE_FREQ" \
  icon="$CODEX_ICON" \
  icon.font="sketchybar-app-font:Regular:14.0" \
  icon.color="$ICON_COLOR" \
  label="${REMAINING_PERCENT}% (${COUNTDOWN})" \
  label.color="$LABEL_COLOR"
