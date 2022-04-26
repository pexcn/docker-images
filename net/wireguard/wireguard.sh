#!/bin/sh
set -e
set -o pipefail

[ "$USE_USERSPACE_MODE" == 1 ] && PATH=/srv/wireguard-go:$PATH

_make_config_secure() {
  chmod 600 /etc/wireguard/*.conf
}

_get_wg_interfaces() {
  ls -A1 /etc/wireguard/*.conf | xargs -n 1 -I {} basename {} .conf
}

_up_wg_interface() {
  for interface in $(_get_wg_interfaces); do
    wg-quick up "$interface"
  done
}

_down_wg_interface() {
  for interface in $(_get_wg_interfaces); do
    wg-quick down "$interface"
  done
}

_graceful_stop() {
  echo "Caught SIGTERM signal, graceful stopping..."
  _down_wg_interface
  _restore_sysctl
}

_apply_sysctl() {
  sysctl "$1" >> /srv/origin.conf
  sysctl -w "$1=$2"
}

_restore_sysctl() {
  sysctl -p /srv/origin.conf
  rm /srv/origin.conf
}

setup_sysctl() {
  [ -f /srv/origin.conf ] && rm /srv/origin.conf

  _apply_sysctl net.ipv4.ip_forward 1
}

start_wireguard() {
  _make_config_secure
  _up_wg_interface

  trap _graceful_stop SIGTERM
  sleep infinity &
  wait
}

setup_sysctl
start_wireguard
