SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCAL_WEATHER_CONFIG="$SCRIPT_DIR/weather.local.sh"

[ -f "$LOCAL_WEATHER_CONFIG" ] && . "$LOCAL_WEATHER_CONFIG"

WEATHER_LOCATION="${WEATHER_LOCATION:-}"
WEATHER_REGION="${WEATHER_REGION:-}"
WEATHER_LANG="${WEATHER_LANG:-en}"

if [ -z "$WEATHER_LOCATION" ]; then
  sketchybar --set "$NAME" label="Weather"
  exit 0
fi

sketchybar --set "$NAME" \
  label="Loading..." \
  icon.color=0xff5edaff

# fetch weather data
# WEATHER_LOCATION and WEATHER_REGION can be set in weather.local.sh
# WEATHER_LANG="ko"

# Line below replaces spaces with +
LOCATION_ESCAPED="${WEATHER_LOCATION// /+}+${WEATHER_REGION// /+}"
WEATHER_JSON=$(curl -s "https://wttr.in/$LOCATION_ESCAPED?0pq&format=j1&lang=$WEATHER_LANG")

# Fallback if empty
if [ -z "$WEATHER_JSON" ]; then
  sketchybar --set "$NAME" label="$WEATHER_LOCATION"
  exit 0
fi

TEMPERATURE=$(echo "$WEATHER_JSON" | jq '.current_condition[0].temp_C' | tr -d '"')
WEATHER_DESCRIPTION=$(echo "$WEATHER_JSON" | jq '.current_condition[0].weatherDesc[0].value' | tr -d '"' | sed 's/\(.\{16\}\).*/\1.../')
# WEATHER_DESCRIPTION=$(echo "$WEATHER_JSON" | jq '.current_condition[0].lang_ko[0].value' | tr -d '"' | sed 's/\(.\{16\}\).*/\1.../')      # for korean

sketchybar --set "$NAME" \
  label="$TEMPERATURE$(echo '°')C • $WEATHER_DESCRIPTION"
