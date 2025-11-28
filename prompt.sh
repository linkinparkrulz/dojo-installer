#! /usr/bin/env bash

if [ -n "${GUARD_PROMPT_INCLUDED:-}" ]; then
  return
fi

GUARD_PROMPT_INCLUDED=1

source "util.sh"

# TODO: Also have a function to adjust the array options. For example: add spaces to the beginning of the right-hand (description) strings
function menubox() {
  local title=${1:-""}
  local message=${2:-""}
  local options=("${@:3}") # all args from 3rd till the end
  local option_count=$((${#options[@]} / 2))
  local height
  height=$(calc_box_height "$message" $option_count)
  local width=80

  local choice
  choice=$(whiptail --title "$title" --menu "$message" --cancel-button "Exit" "$height" "$width" "$option_count" "${options[@]}" 3>&1 1>&2 2>&3)
  [ -n "$choice" ] && echo "${choice,,}" || return 1
}

function inputbox() {
  local title=${1:-""}
  local message=${2:-""}
  local placeholder=${3:-""}
  local height
  height=$(calc_box_height "$message")
  local width=80

  local choice
  choice=$(whiptail --title "$title" --inputbox "$message" "$height" "$width" "$placeholder" 3>&1 1>&2 2>&3)
  echo "$choice"
}

function msgbox() {
  local title=${1:-""}
  local message=${2:-""}
  local height
  height=$(calc_box_height "$message")
  local width=80

  whiptail --title "$title" --msgbox "$message" "$height" "$width" 3>&1 1>&2 2>&3
}

function confirmbox() {
  local title=${1:-""}
  local message=${2:-""}
  local height
  height=$(calc_box_height "$message")
  local width=80

  whiptail --title "$title" --yesno "$message" "$height" "$width" 3>&1 1>&2 2>&3
}
