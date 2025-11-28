#! /usr/bin/env bash

if [ -n "${GUARD_REVIEW_INCLUDED:-}" ]; then
  return
fi

GUARD_REVIEW_INCLUDED=1

source "prompt.sh"
source "dbcache.sh"
source "network.sh"
source "settings.sh"

function confirm_installation() {
  local msg_array=(
    "Dojo will be installed with the following settings:\n\n"
    "Network: $(get_network)\n"
    "Electrum Server: Fulcrum\n"
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
  echo "changing dir to $(dirname "$0")/samourai-dojo/docker/my-dojo/"
  cd "$(dirname "$0")/samourai-dojo/docker/my-dojo/" || exit 1
  
  if [ -f "dojo.sh" ] && [ -x "dojo.sh" ]; then
    msgbox "Installation Starting" "Dojo installation is now starting!\n\nYou will see many messages appear as Docker downloads and builds the containers.\n\nPlease wait until you see bitcoind synchronization logs, then you can press Ctrl+C to exit the installer.\n\nThe installation will continue running in the background."
    ./dojo.sh install
  fi
  
  exit
}
