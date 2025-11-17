#! /usr/bin/env bash

if [ -n "${GUARD_MAINMENU_INCLUDED:-}" ]; then
  return
fi

GUARD_MAINMENU_INCLUDED=1

source "prompt.sh"
source "review.sh"
source "dbcache.sh"
source "network.sh"
source "electrum.sh"

function main_menu() {
  local choice
  local options=(
    "1 Network" "  Select network"
    "2 Dependencies" "  Check if all dependencies are installed"
    "3 Electrum Server" "  Choose Electrum Server"
    "4 Settings" "  Adjust bitcoind settings"
    "5 Install" "  Review settings and install"
    "6 Exit" "  Exit the installer"
  )

  while true; do
    choice=$(menubox "Main Menu" "" "${options[@]}")
    choice=${choice:0:1}

    echo "Main menu choice: $choice"
    case "$choice" in
    1)
      read_network
      ;;
    2)
      msgbox "Review Settings" "Pending"
      ;;
    3)
      read_electrum
      ;;
    4)
      read_dbcache
      ;;
    5)
      confirm_installation && install_dojo
      ;;
    6)
      confirmbox "Exit" "Do you really want to exit the installer?" && exit
      ;;
    *)
      confirmbox "Exit" "Do you really want to exit the installer?" && exit
    esac
  done

}
