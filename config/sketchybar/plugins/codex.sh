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

PRIMARY_POPUP_ITEM="codex.limit.primary"
SECONDARY_POPUP_ITEM="codex.limit.secondary"
USAGE_BAR_SEGMENTS=20

format_usage_bar() {
  local remaining_percent="$1"
  local filled_segments=$(((remaining_percent * USAGE_BAR_SEGMENTS + 50) / 100))
  local segment
  local bar=""

  for ((segment = 0; segment < USAGE_BAR_SEGMENTS; segment++)); do
    if (( segment < filled_segments )); then
      bar+="█"
    else
      bar+="░"
    fi
  done

  printf '%s' "$bar"
}

set_unavailable() {
  local empty_bar

  [[ -n "$SKETCHYBAR_BIN" ]] || return 0
  empty_bar="$(format_usage_bar 0)"

  "$SKETCHYBAR_BIN" --set "${NAME:-codex}" \
    icon="$CODEX_ICON" \
    icon.font="sketchybar-app-font:Regular:14.0" \
    icon.color="$GREY" \
    label="—" \
    label.color="$GREY" \
    --set "$PRIMARY_POPUP_ITEM" \
    icon="5h limit:" \
    icon.color="$GREY" \
    label="${empty_bar}  —" \
    label.color="$GREY" \
    --set "$SECONDARY_POPUP_ITEM" \
    icon="7d limit:" \
    icon.color="$GREY" \
    label="${empty_bar}  —" \
    label.color="$GREY"
}

if [[ -z "$SKETCHYBAR_BIN" || -z "$CODEX_BIN" || -z "$JQ_BIN" || -z "$PERL_BIN" ]]; then
  set_unavailable
  exit 0
fi

REQUESTS=$'{"id":1,"method":"initialize","params":{"clientInfo":{"name":"sketchybar-codex-usage","version":"1.0"}}}\n{"id":2,"method":"account/rateLimits/read"}'

# Keep a slow or unavailable app-server from blocking SketchyBar updates.
SERVER_TIMEOUT_SECONDS=15
RUNTIME_DIR="$(mktemp -d "${TMPDIR:-/tmp}/sketchybar-codex.XXXXXX" 2>/dev/null || true)"

if [[ -z "$RUNTIME_DIR" ]]; then
  set_unavailable
  exit 0
fi

REQUEST_PIPE="$RUNTIME_DIR/requests"
RESPONSE_FILE="$RUNTIME_DIR/responses"
SERVER_PID=""
REQUEST_FD_OPEN=false

cleanup_server() {
  if [[ "$REQUEST_FD_OPEN" == true ]]; then
    exec 3>&-
    REQUEST_FD_OPEN=false
  fi

  if [[ -n "$SERVER_PID" ]]; then
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
    SERVER_PID=""
  fi

  rm -f "$REQUEST_PIPE" "$RESPONSE_FILE"
  rmdir "$RUNTIME_DIR" 2>/dev/null || true
}

if ! mkfifo "$REQUEST_PIPE" || ! : >"$RESPONSE_FILE"; then
  cleanup_server
  set_unavailable
  exit 0
fi

trap cleanup_server EXIT

"$PERL_BIN" -e 'alarm 17; exec @ARGV' \
  "$CODEX_BIN" app-server --listen stdio:// \
  <"$REQUEST_PIPE" >"$RESPONSE_FILE" 2>/dev/null &
SERVER_PID=$!

# Keep stdin open until the requested response arrives. Closing it after a fixed
# delay can make app-server drop a valid response when a backend request is slow.
exec 3>"$REQUEST_PIPE"
REQUEST_FD_OPEN=true
printf '%s\n' "$REQUESTS" >&3

RATE_LIMIT_RESULT=""
attempt=0
max_attempts=$((SERVER_TIMEOUT_SECONDS * 5))

while (( attempt < max_attempts )); do
  RATE_LIMIT_RESULT="$(
    "$JQ_BIN" -cer 'select(.id == 2 and .result != null) | .result' \
      "$RESPONSE_FILE" 2>/dev/null |
      tail -n 1
  )"

  if [[ -n "$RATE_LIMIT_RESULT" ]] || ! kill -0 "$SERVER_PID" 2>/dev/null; then
    break
  fi

  sleep 0.2
  attempt=$((attempt + 1))
done

cleanup_server
trap - EXIT

if [[ -z "$RATE_LIMIT_RESULT" ]]; then
  set_unavailable
  exit 0
fi

PRIMARY_USAGE_DATA="$(
  printf '%s\n' "$RATE_LIMIT_RESULT" |
    "$JQ_BIN" -er '
      (.rateLimitsByLimitId.codex.primary // .rateLimits.primary // empty)
      | select(.usedPercent != null and .resetsAt != null)
      | [.usedPercent, .resetsAt, (.windowDurationMins // 300)]
      | @tsv
    ' 2>/dev/null
)"

if [[ -z "$PRIMARY_USAGE_DATA" ]]; then
  set_unavailable
  exit 0
fi

IFS=$'\t' read -r PRIMARY_USED_PERCENT PRIMARY_RESET_AT PRIMARY_WINDOW_DURATION_MINS <<<"$PRIMARY_USAGE_DATA"

if [[ ! "$PRIMARY_USED_PERCENT" =~ ^[0-9]+$ ||
      ! "$PRIMARY_RESET_AT" =~ ^[0-9]+$ ||
      "$PRIMARY_USED_PERCENT" -gt 100 ]]; then
  set_unavailable
  exit 0
fi

if [[ ! "$PRIMARY_WINDOW_DURATION_MINS" =~ ^[0-9]+$ ||
      "$PRIMARY_WINDOW_DURATION_MINS" -eq 0 ]]; then
  PRIMARY_WINDOW_DURATION_MINS=300
fi

SECONDARY_USAGE_DATA="$(
  printf '%s\n' "$RATE_LIMIT_RESULT" |
    "$JQ_BIN" -er '
      (.rateLimitsByLimitId.codex.secondary // .rateLimits.secondary // empty)
      | select(.usedPercent != null and .resetsAt != null)
      | [.usedPercent, .resetsAt, (.windowDurationMins // 10080)]
      | @tsv
    ' 2>/dev/null
)"

format_countdown() {
  local reset_at="$1"
  local seconds_until_reset=$((reset_at - NOW))
  local days hours minutes

  if (( seconds_until_reset < 0 )); then
    seconds_until_reset=0
  fi

  if (( seconds_until_reset > 86400 )); then
    days=$((seconds_until_reset / 86400))
    hours=$(((seconds_until_reset % 86400) / 3600))
    printf '%dd %02dh' "$days" "$hours"
  else
    hours=$((seconds_until_reset / 3600))
    minutes=$(((seconds_until_reset % 3600) / 60))
    printf '%02dh %02dm' "$hours" "$minutes"
  fi
}

format_window_name() {
  local duration_mins="$1"

  if (( duration_mins % 1440 == 0 )); then
    printf '%dd limit:' "$((duration_mins / 1440))"
  elif (( duration_mins % 60 == 0 )); then
    printf '%dh limit:' "$((duration_mins / 60))"
  else
    printf '%dm limit:' "$duration_mins"
  fi
}

format_reset_time() {
  local reset_at="$1"
  local duration_mins="$2"
  local formatted_reset

  if (( duration_mins <= 1440 )); then
    formatted_reset="$(LC_ALL=C TZ=Asia/Seoul date -r "$reset_at" '+%-I:%M %p' 2>/dev/null)"
  else
    formatted_reset="$(LC_ALL=C TZ=Asia/Seoul date -r "$reset_at" '+%b %-d' 2>/dev/null)"
  fi

  printf '%s' "${formatted_reset:-—}"
}

format_popup_usage() {
  local remaining_percent="$1"
  local reset_at="$2"
  local duration_mins="$3"
  local usage_bar reset_time

  usage_bar="$(format_usage_bar "$remaining_percent")"
  reset_time="$(format_reset_time "$reset_at" "$duration_mins")"
  printf '%s  %d%% left (resets %s)' "$usage_bar" "$remaining_percent" "$reset_time"
}

NOW="$(date +%s)"
PRIMARY_REMAINING_PERCENT=$((100 - PRIMARY_USED_PERCENT))
PRIMARY_COUNTDOWN="$(format_countdown "$PRIMARY_RESET_AT")"
LABEL="${PRIMARY_REMAINING_PERCENT}% (${PRIMARY_COUNTDOWN})"
PRIMARY_WINDOW_NAME="$(format_window_name "$PRIMARY_WINDOW_DURATION_MINS")"
PRIMARY_POPUP_LABEL="$(
  format_popup_usage \
    "$PRIMARY_REMAINING_PERCENT" \
    "$PRIMARY_RESET_AT" \
    "$PRIMARY_WINDOW_DURATION_MINS"
)"

EMPTY_USAGE_BAR="$(format_usage_bar 0)"
SECONDARY_WINDOW_NAME="7d limit:"
SECONDARY_POPUP_LABEL="${EMPTY_USAGE_BAR}  —"
SECONDARY_POPUP_COLOR="$GREY"

if [[ -n "$SECONDARY_USAGE_DATA" ]]; then
  IFS=$'\t' read -r \
    SECONDARY_USED_PERCENT \
    SECONDARY_RESET_AT \
    SECONDARY_WINDOW_DURATION_MINS <<<"$SECONDARY_USAGE_DATA"

  if [[ "$SECONDARY_USED_PERCENT" =~ ^[0-9]+$ &&
        "$SECONDARY_RESET_AT" =~ ^[0-9]+$ &&
        "$SECONDARY_USED_PERCENT" -le 100 ]]; then
    if [[ ! "$SECONDARY_WINDOW_DURATION_MINS" =~ ^[0-9]+$ ||
          "$SECONDARY_WINDOW_DURATION_MINS" -eq 0 ]]; then
      SECONDARY_WINDOW_DURATION_MINS=10080
    fi

    SECONDARY_REMAINING_PERCENT=$((100 - SECONDARY_USED_PERCENT))
    SECONDARY_COUNTDOWN="$(format_countdown "$SECONDARY_RESET_AT")"
    LABEL+=" / ${SECONDARY_REMAINING_PERCENT}% (${SECONDARY_COUNTDOWN})"
    SECONDARY_WINDOW_NAME="$(format_window_name "$SECONDARY_WINDOW_DURATION_MINS")"
    SECONDARY_POPUP_LABEL="$(
      format_popup_usage \
        "$SECONDARY_REMAINING_PERCENT" \
        "$SECONDARY_RESET_AT" \
        "$SECONDARY_WINDOW_DURATION_MINS"
    )"
    SECONDARY_POPUP_COLOR="$LABEL_COLOR"
  fi
fi

SECONDS_UNTIL_PRIMARY_RESET=$((PRIMARY_RESET_AT - NOW))
if (( SECONDS_UNTIL_PRIMARY_RESET > 86400 )); then
  UPDATE_FREQ=300
else
  UPDATE_FREQ=60
fi

"$SKETCHYBAR_BIN" --set "${NAME:-codex}" \
  update_freq="$UPDATE_FREQ" \
  icon="$CODEX_ICON" \
  icon.font="sketchybar-app-font:Regular:14.0" \
  icon.color="$ICON_COLOR" \
  label="$LABEL" \
  label.color="$LABEL_COLOR" \
  --set "$PRIMARY_POPUP_ITEM" \
  icon="$PRIMARY_WINDOW_NAME" \
  icon.color="$GREY" \
  label="$PRIMARY_POPUP_LABEL" \
  label.color="$LABEL_COLOR" \
  --set "$SECONDARY_POPUP_ITEM" \
  icon="$SECONDARY_WINDOW_NAME" \
  icon.color="$GREY" \
  label="$SECONDARY_POPUP_LABEL" \
  label.color="$SECONDARY_POPUP_COLOR"
