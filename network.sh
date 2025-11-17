#! /usr/bin/env bash

if [ -n "${GUARD_NETWORK_INCLUDED:-}" ]; then
  return
fi

GUARD_NETWORK_INCLUDED=1

source "prompt.sh"
source "settings.sh"

function menu_network() {
  local opt=(
    "Mainnet" "  Normal installation"
    "Testnet" "  For testing purposes"
  )

  menubox "Network" "Select network:" "${opt[@]}"
}

function read_network() {
  local network
  if network=$(menu_network); then
    set_network "$network"
  fi
}
