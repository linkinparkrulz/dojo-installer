#! /usr/bin/env bash

source "system.sh"
source "settings.sh"
source "prompt.sh"
source "dbcache.sh"
source "network.sh"
source "electrum.sh"
source "main-menu.sh"
source "review.sh"
source "welcome.sh"
source "express-install.sh"

function check_whiptail() {
  if ! is_installed whiptail; then
    echo "The installer requires whiptail, but whiptail was not found" >&2
    exit 1
  fi
}

function main() {
  check_whiptail

  welcome_dialog
  if express_install && confirm_installation; then
    install_dojo
  else
    main_menu
  fi

  echo "Settings:"
  echo "Network: $(get_network)"
  echo "dbcache: $(get_dbcache)"
  echo "Electrum: $(get_electrum)"
}

main
