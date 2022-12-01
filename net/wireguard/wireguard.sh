#!/bin/sh

info() {
  local green='\e[0;32m'
  local clear='\e[0m'
  local time=$(date '+%Y-%m-%d %T')
  printf "${green}[${time}] [INFO]: ${clear}%s\n" "$*"
}

warn() {
  local yellow='\e[1;33m'
  local clear='\e[0m'
  local time=$(date '+%Y-%m-%d %T')
  printf "${yellow}[${time}] [WARN]: ${clear}%s\n" "$*" >&2
}

_get_wg_interfaces() {
  find /etc/wireguard -maxdepth 1 -type f -name "*.conf" -exec basename -a -s ".conf" {} +
}

_graceful_stop() {
  warn "caught SIGTERM or SIGINT signal, graceful stopping..."

  for interface in $(_get_wg_interfaces); do
    info "[${interface}]: interface down."
    wg-quick down "$interface"
  done

  exit 0
}

setup_environment() {
  [ "$USE_USERSPACE_MODE" != 1 ] || PATH="/srv/bin:$PATH"

  # make configs be safe
  chmod 600 /etc/wireguard/*.conf

  # makesure ip_forward enabled
  sysctl -wq net.ipv4.ip_forward=1
}

start_wireguard() {
  trap _graceful_stop SIGTERM SIGINT

  for interface in $(_get_wg_interfaces); do
    info "[${interface}]: interface up."
    wg-quick up "$interface"
  done

  if [ "$PEER_RESOLVE_INTERVAL" = 0 ]; then
    info "sleep infinity."
    sleep infinity &
    wait
  else
    while true; do
      info "sleep ${PEER_RESOLVE_INTERVAL} seconds."
      sleep "$PEER_RESOLVE_INTERVAL" &
      wait
      for cfg in /etc/wireguard/*.conf; do
        info "[$(basename ${cfg} .conf)]: interval refresh endpoint."
        reresolve-dns.sh "$cfg"
      done
    done
  fi
}

setup_environment
start_wireguard
