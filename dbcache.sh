#! /usr/bin/env bash

if [ -n "${GUARD_DBCACHE_INCLUDED:-}" ]; then
  return
fi

GUARD_DBCACHE_INCLUDED=1

source "prompt.sh"
source "settings.sh"

function menu_dbcache() {
  local current_dbcache
  current_dbcache=$(get_dbcache)
  
  local msg="Current dbcache: ${current_dbcache} MiB\n\n"
  msg+="Select dbcache size (in MiB):\n\n"
  msg+="Recommendations:\n"
  msg+="• 512 MiB: Minimum for basic usage\n"
  msg+="• 1024 MiB: Good for most users (default)\n"
  msg+="• 2048 MiB: Better performance\n"
  msg+="• 4096 MiB: High performance systems\n"
  msg+="• 8192 MiB: Maximum performance\n\n"
  msg+="Note: More dbcache uses more RAM but speeds up initial sync."

  local choice
  choice=$(inputbox "Database Cache" "$msg" "$current_dbcache")
  
  if [ -n "$choice" ] && [[ "$choice" =~ ^[0-9]+$ ]]; then
    # Validate the input is a reasonable number
    if [ "$choice" -ge 512 ] && [ "$choice" -le 16384 ]; then
      set_dbcache "$choice"
      msgbox "Database Cache" "Database cache set to ${choice} MiB"
    else
      msgbox "Invalid Input" "Please enter a value between 512 and 16384 MiB"
    fi
  elif [ -n "$choice" ]; then
    msgbox "Invalid Input" "Please enter a valid number"
  fi
}

function read_dbcache() {
  menu_dbcache
}
