#! /usr/bin/env bash

if [ -n "${GUARD_WELCOME_INCLUDED:-}" ]; then
  return
fi

GUARD_WELCOME_INCLUDED=1

source "prompt.sh"

function welcome_dialog() {
  local msg_array=(
    "Welcome to the Dojo Installer.\n\n"
    "This will install the MyDojo package, which contains:\n"
    "- Bitcoin Core\n- Fulcrum Electrum Server\n- Dojo\n- Tor\n\n"
    # "The next screen will display the main menu, in which you can choose which software to install and define some settings.\n\n"
    "At the end, a summary will be displayed, so you can review and confirm installation should start."
  )
  
  local msg
  msg=$(printf "%s" "${msg_array[@]}")

  msgbox "Dojo Installer" "$msg"
}
