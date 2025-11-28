#! /usr/bin/env bash

# declare -A settings
# settings["network"]="mainnet"
# settings["dbcache"]="2000"


# for key in "${!settings[@]}"; do
#   echo "$key"
#   echo "${settings[$key]}"
#   echo
# done

source "util.sh"

echo "here we use what we need from util:"
num=000100000
echo "num: $num"
echo "let's trim"
num=$(trim_zeros $num)
echo "num: $num"


echo "now I call source again:"
source "util.sh"
echo "last line"

echo "is the variable available here? $_DOJOINSTALLER_UTIL"
