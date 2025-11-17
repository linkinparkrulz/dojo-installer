#! /usr/bin/env bash

if [ -n "${GUARD_REVIEW_INCLUDED:-}" ]; then
  return
fi

GUARD_REVIEW_INCLUDED=1

source "prompt.sh"
source "dbcache.sh"
source "network.sh"
source "electrum.sh"
source "settings.sh"

function confirm_installation() {
  local electrum
  electrum=$(get_electrum)

  local msg_array=(
    "Dojo will be installed with the following settings:\n\n"
    "Network: $(get_network)\n"
    "Electrum Server: ${electrum^}\n"
    "dbcache: $(get_dbcache) MiB\n"
    "Fee rate: 1 sat/vb\n"
    "\n"
    "Proceed with installation?"
  )

  local msg
  msg=$(printf "%s" "${msg_array[@]}")

  confirmbox "Confirm Installation" "$msg"
}

function install_dojo() {
  write_config_files
  echo "changing dir to $(dirname "$0")/dojo-app/docker/my-dojo/"
  cd "$(dirname "$0")/dojo-app/docker/my-dojo/" || exit 1
  
  if [ -f "dojo.sh" ] && [ -x "dojo.sh" ]; then
    echo "TODO: Display a messagebox saying installation is starting, lots of messages will appear, wait until bitcoind logs etc, then Ctrl + C to exit"
    ./dojo.sh install
  fi
  
  exit
}
