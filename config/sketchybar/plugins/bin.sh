#!/usr/bin/env bash

find_command() {
  local name="$1"
  local path

  path="$(command -v "$name" 2>/dev/null)"
  if [[ -n "$path" ]]; then
    printf '%s' "$path"
    return 0
  fi

  for path in \
    "/opt/homebrew/bin/$name" \
    "/usr/local/bin/$name" \
    "/usr/bin/$name" \
    "/bin/$name"; do
    if [[ -x "$path" ]]; then
      printf '%s' "$path"
      return 0
    fi
  done

  return 1
}
