#! /usr/bin/env bash

if [ -n "${GUARD_DBCACHE_INCLUDED:-}" ]; then
  return
fi

GUARD_DBCACHE_INCLUDED=1

source "system.sh"
source "settings.sh"
source "prompt.sh"
source "util.sh"

function input_dbcache() {
  local default_ram=1024
  local total_ram
  total_ram=$(get_system_memory)

  local ram_info=""
  if [ "$total_ram" -gt 0 ]; then
    ram_info="\nIt seems your system has $total_ram MiB available.\n\n"
  fi

  local title="Config dbcache"
  local msg_array=(
    "The dbcache setting defines the maximum amount of memory (RAM) for bitcoind's database cache.\n\n"
    "Bigger values make the initial sync faster by reducing the frequency of disk writes.\n"
    "$ram_info"
    "Enter the value of dbcache in MiB (default $default_ram MiB):"
  )

  local msg
  msg=$(printf "%s" "${msg_array[@]}")

  local answer
  while true; do
    answer=$(inputbox "$title" "$msg" "$(get_dbcache)")

    if [ -z "$answer" ]; then # empty, keep previous value
      answer=$(get_dbcache)
      break
    fi

    if ! echo "$answer" | grep -qE "^[0-9]+$"; then # invalid, repeat
      msgbox "Invalid input" "Please enter a number for dbcache."
      continue
    fi

    answer="$(trim_zeros "$answer")"

    if [ "$total_ram" -gt 0 ] && [ "$answer" -gt "$total_ram" ]; then # bigger than detected, ok if confirmed
      local confirm_msg="Are you sure you want $answer MiB for dbcache?\nOnly $total_ram MiB was detected."
      confirmbox "Value above detected RAM" "$confirm_msg" && break
    elif [ "$answer" -ge "$default_ram" ]; then # ok value
      break
    else
      local confirm_msg="Are you sure you want $answer MiB for dbcache?\nThe recommended minimum is $default_ram MiB."
      confirmbox "Value below default" "$confirm_msg" && break # below default, ok if confirmed
    fi
  done

  echo "$answer"
}

function read_dbcache() {
  local dbcache
  dbcache=$(input_dbcache)
  set_dbcache "$dbcache"
}
