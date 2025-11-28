#! /usr/bin/env bash

if [ -n "${GUARD_EXPRESSINSTALL_INCLUDED:-}" ]; then
  return
fi

GUARD_EXPRESSINSTALL_INCLUDED=1

source "prompt.sh"

function express_install() {
  local msg_array=(
    "Would you like to install Dojo using the default settings?\n\n"
    "You can review the settings in the next screen.\n\n"
    "Otherwise, choose \"no\" to be able to configure them."
  )
  
  local msg
  msg=$(printf "%s" "${msg_array[@]}")

  confirmbox "Express Install" "$msg"
}
