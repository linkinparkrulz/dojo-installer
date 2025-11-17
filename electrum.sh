#! /usr/bin/env bash

if [ -n "${GUARD_ELECTRUM_INCLUDED:-}" ]; then
  return
fi

GUARD_ELECTRUM_INCLUDED=1

source "prompt.sh"
source "settings.sh"

function menu_electrum() {
  local opt=(
    "Fulcrum" "  Faster, needs more disk space"
    "Electrs" "  Slower, less disk space"
  )

  menubox "Electrum Server" "Select an Electrum Server:" "${opt[@]}"
}

function read_electrum() {
  local electrum
  if electrum=$(menu_electrum); then
    echo "ignoring $electrum option, remove it from the menu later"
  fi
}
