#! /usr/bin/env bash

if [ -n "${GUARD_UTIL_INCLUDED:-}" ]; then
  return
fi

GUARD_UTIL_INCLUDED=1

source "system.sh"

# Return the argument number without leading zeros
function trim_zeros() {
  local num="$1"
  echo $((10#$num)) # make sure to use base 10
}

# Generate and return a random password using pwgen (if installed) or /dev/urandom
function generate_pass() {
  local pass
  local length=64
  
  if is_installed pwgen; then
    pass=$(pwgen --secure "$length" 1)
  else
    pass=$(tr -cd '[:alnum:]' </dev/urandom | head -c"$length")
  fi

  if [ ${#pass} -ne "$length" ]; then
    echo "Something wrong happened - password expected to have $length chars" >&2
    exit 1
  fi

  echo "$pass"
}

# Calculate height of box based on the number of lines in the message
function calc_box_height() {
  # TODO: make it 2 or 3 pre-defined sizes, like small|big
  echo 20
}
