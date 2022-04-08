#!/bin/sh

set -e
set -o pipefail

# TODO: restore sysctl state function
apply_sysctl() {
  sysctl -w net.ipv4.ip_forward=1
}

apply_sysctl



_term() {
  echo "Caught SIGTERM signal!"
  wg-quick down wg-server
}

trap _term SIGTERM
wg-quick up wg-server
sleep infinity &
wait
