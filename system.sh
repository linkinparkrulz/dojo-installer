#! /usr/bin/env bash

if [ -n "${GUARD_SYSTEM_INCLUDED:-}" ]; then
  return
fi

GUARD_SYSTEM_INCLUDED=1

# Return the total system memory in gigabytes (GB).
# Note: A return value of zero indicates that RAM could not be retrieved.
function get_system_memory() {
  local ram_kb
  ram_kb=$(grep MemTotal /proc/meminfo | tr -cd '[:digit:]')
  echo "$((ram_kb / 1000))"
}

# Return whether a command/program is installed or not.
function is_installed() {
  local program="$1"
  command -v "$program" >/dev/null
}
