#!/bin/sh
set -e
set -o pipefail

[ "$USE_USERSPACE_MODE" != 1 ] || PATH=/srv/wireguard-go:$PATH

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

_backup_sysctl() {
  sysctl "$1" >> /tmp/sysctl-origin.conf
}

_restore_sysctl() {
  sysctl -pq /tmp/sysctl-origin.conf
  rm /tmp/sysctl-origin.conf
}

_apply_sysctl() {
  [ $(sysctl -n "$1") = "$2" ] || sysctl -wq "$1"="$2"
}

setup_sysctl() {
  [ ! -f /tmp/sysctl-origin.conf ] || rm /tmp/sysctl-origin.conf
  _backup_sysctl net.ipv4.ip_forward
  _apply_sysctl net.ipv4.ip_forward 1
}

start_wireguard() {
  trap _graceful_stop SIGTERM

  _make_config_secure
  _up_wg_interface

  if [[ -z "$PEER_RESOLVE_INTERVAL" || "$PEER_RESOLVE_INTERVAL" = 0 ]]; then
    sleep infinity &
    wait
  else
    while true
    do
      sleep "$PEER_RESOLVE_INTERVAL" &
      wait
      for cfg in /etc/wireguard/*.conf; do reresolve-dns.sh "$cfg"; done
    done
  fi
}

setup_sysctl
start_wireguard
