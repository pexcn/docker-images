#!/bin/sh
set -e
set -o pipefail

_graceful_stop() {
  echo "Caught SIGTERM signal, graceful stop!"
  for interface in $(_get_wireguard_interfaces); do
    wg-quick down "$interface"
  done
}

_get_wireguard_interfaces() {
  basename -s .conf /etc/wireguard/*
}

# TODO: restore sysctl state function
apply_sysctl() {
  sysctl -w net.ipv4.ip_forward=1
}

start_wireguard() {
  for interface in $(_get_wireguard_interfaces); do
    wg-quick up "$interface"
  done

  trap _graceful_stop SIGTERM
  sleep infinity &
  wait
}

apply_sysctl
start_wireguard
