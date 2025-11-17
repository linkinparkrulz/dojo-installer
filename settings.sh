#! /usr/bin/env bash

if [ -n "${GUARD_SETTINGS_INCLUDED:-}" ]; then
  return
fi

GUARD_SETTINGS_INCLUDED=1

# TODO: Add explorer install, remove electrs option

source "util.sh"

declare -A settings=(
  [network]="mainnet"
  [dbcache]=1024
  [electrum]="fulcrum"
  [feerate]="1"
)

function set_network() {
  settings[network]="$1"
}

function get_network() {
  echo "${settings[network]}"
}

function set_electrum() {
  settings[electrum]="$1"
}

function get_electrum() {
  echo "${settings[electrum]}"
}

function set_dbcache() {
  settings[dbcache]="$1"
}

function get_dbcache() {
  echo "${settings[dbcache]}"
}

function set_feerate() {
  settings[feerate]="$1"
}

function get_feerate() {
  echo "${settings[feerate]}"
}

function write_config_files() {
  local base_dir
  base_dir="$(dirname "$0")/dojo-app/docker/my-dojo"
  local bitcoind_file="$base_dir/conf/docker-bitcoind.conf.tpl"
  local common_file="$base_dir/conf/docker-common.conf.tpl"
  local mysql_file="$base_dir/conf/docker-mysql.conf.tpl"
  local nodejs_file="$base_dir/conf/docker-node.conf.tpl"
  local indexer_file="$base_dir/conf/docker-indexer.conf.tpl"

  echo "writing $bitcoind_file"
  sed -i "/^BITCOIND_RPC_USER=/c\BITCOIND_RPC_USER=dojorpc" "$bitcoind_file"
  sed -i "/^BITCOIND_RPC_PASSWORD=/c\BITCOIND_RPC_PASSWORD=$(generate_pass)" "$bitcoind_file"
  sed -i "/^BITCOIND_DB_CACHE=/c\BITCOIND_DB_CACHE=$(get_dbcache)" "$bitcoind_file"
  # sed -i "/^BITCOIND_MIN_RELAY_TX_FEE=/c\BITCOIND_MIN_RELAY_TX_FEE=0.000001" "$bitcoind_file" # TODO: see if it's worth adding this, v30 does already have 0.1 sat/vb as default

  echo "writing $common_file"
  sed -i "/^COMMON_BTC_NETWORK=/c\COMMON_BTC_NETWORK=$(get_network)" "$common_file"

  echo "writing $mysql_file"
  sed -i "/^MYSQL_ROOT_PASSWORD=/c\MYSQL_ROOT_PASSWORD=$(generate_pass)" "$mysql_file"
  sed -i "/^MYSQL_USER=/c\MYSQL_USER=samourai" "$mysql_file"
  sed -i "/^MYSQL_PASSWORD=/c\MYSQL_PASSWORD=$(generate_pass)" "$mysql_file"

  echo "writing $nodejs_file"
  sed -i "/^NODE_API_KEY=/c\NODE_API_KEY=$(generate_pass)" "$nodejs_file"
  sed -i "/^NODE_ADMIN_KEY=/c\NODE_ADMIN_KEY=$(generate_pass)" "$nodejs_file"
  sed -i "/^NODE_JWT_SECRET=/c\NODE_JWT_SECRET=$(generate_pass)" "$nodejs_file"
  sed -i "/^NODE_ACTIVE_INDEXER=/c\NODE_ACTIVE_INDEXER=local_indexer" "$nodejs_file"

  echo "writing $indexer_file"
  sed -i "/^INDEXER_INSTALL=/c\INDEXER_INSTALL=on" "$indexer_file"
  sed -i "/^INDEXER_TYPE=/c\INDEXER_TYPE=fulcrum" "$indexer_file"
  sed -i "/^INDEXER_BATCH_SUPPORT=/c\INDEXER_BATCH_SUPPORT=active" "$indexer_file"
}

