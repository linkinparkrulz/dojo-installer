#! /usr/bin/env bash

source "splash.sh"
source "system.sh"
source "settings.sh"
source "prompt.sh"
source "dependencies.sh"
source "dbcache.sh"
source "network.sh"
source "main-menu.sh"
source "review.sh"
source "welcome.sh"
source "paynym.sh"
source "express-install.sh"

function check_whiptail() {
  if ! is_installed whiptail; then
    echo "The installer requires whiptail, but whiptail was not found" >&2
    exit 1
  fi
}

function main() {
  check_whiptail

  # Setup dark theme
  setup_dark_theme

  # Show splash screen first
  show_splash

  welcome_dialog
  
  # Setup Paynym payment code (if not already configured)
  if ! is_payment_code_configured; then
    setup_paynym_payment_code
  fi
  
  if express_install && confirm_installation; then
    # Check dependencies before actual installation
    if ! check_and_install_dependencies; then
      echo "Dependency check failed. Please resolve the issues and run the installer again."
      exit 1
    fi
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
