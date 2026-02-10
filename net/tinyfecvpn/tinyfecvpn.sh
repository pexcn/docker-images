#!/bin/sh
# shellcheck disable=SC2155,SC3043,SC3060,SC3048

TUNDEV="tinyfecvpn"
SUBNET="10.22.22.0"
PORT="null"

# alias ​​settings must be global, and must be defined before the function being called with the alias
if [ "$USE_IPTABLES_NFT_BACKEND" = 1 ]; then
  alias iptables=iptables-nft
  alias iptables-save=iptables-nft-save
else
  alias iptables=iptables-legacy
  alias iptables-save=iptables-legacy-save
fi

info() {
  local green='\e[0;32m'
  local clear='\e[0m'
  local time="$(date '+%Y-%m-%d %T')"
  printf "${green}[${time}] [INFO]: ${clear}%s\n" "$*"
}

warn() {
  local yellow='\e[1;33m'
  local clear='\e[0m'
  local time="$(date '+%Y-%m-%d %T')"
  printf "${yellow}[${time}] [WARN]: ${clear}%s\n" "$*" >&2
}

error() {
  local red='\e[0;31m'
  local clear='\e[0m'
  local time="$(date '+%Y-%m-%d %T')"
  printf "${red}[${time}] [ERROR]: ${clear}%s\n" "$*" >&2
}

_get_default_iface() {
  ip -o -4 route show default | awk '/default/ {print $5}'
}

_get_addr_by_iface() {
  ip -o -4 addr show dev "$1" scope global | awk '{split($4,a,"/"); print a[1]; exit}'
}

_is_server_mode() {
  [ "$1" = "-s" ]
}

_is_exist_rule() {
  iptables-save | grep -q "$1"
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --tun-dev) TUNDEV=$2; shift 2 ;;
      --sub-net) SUBNET=$2; shift 2 ;;
      -l|-r) PORT=${2##*:}; shift 2 ;;
      *) shift ;;
    esac
  done
}

apply_sysctl() {
  [ "$(sysctl -n net.ipv4.ip_forward)" = 0 ] || return
  info "apply sysctl: $(sysctl -w net.ipv4.ip_forward=1)"
}

apply_iptables() {
  local interface="$(_get_default_iface)"
  local address="$(_get_addr_by_iface "$interface")"
  local comment="tinyfecvpn_${TUNDEV}_${PORT}"

  if _is_exist_rule "${comment}"; then
    warn "iptables rules already exist, maybe needs to check."
  else
    # shellcheck disable=SC2015
    iptables -w 10 -t nat -A POSTROUTING -s "${SUBNET}/30" -o "$interface" -j SNAT --to-source "$address" -m comment --comment "${comment}" \
      && info "iptables SNAT rule added: [${comment}]: ${TUNDEV} -> ${interface}, ${SUBNET} -> ${address}" \
      || error "iptables rule add failed."
  fi
}

stop_process() {
  kill "$(pidof tinyfecvpn)"
  info "terminate tinyfecvpn process."
}

revoke_iptables() {
  local tundev="$TUNDEV"
  local port="$PORT"
  local comment="tinyfecvpn_${tundev}_${port}"

  iptables-save -t nat | grep "${comment}" | while read -r rule; do
    iptables -w 10 -t nat "${rule/-A POSTROUTING/-D POSTROUTING}" || error "iptables rule remove failed."
  done
  info "iptables SNAT rule removed: [${comment}]."
}

graceful_stop() {
  warn "caught SIGTERM or SIGINT signal, graceful stopping..."
  revoke_iptables
  stop_process
}

start_tinyfecvpn() {
  if _is_server_mode "$1"; then
    trap 'graceful_stop' SIGTERM SIGINT
    parse_args "$@"
    apply_sysctl
    apply_iptables
    tinyfecvpn "$@" &
    wait $!
  else
    exec tinyfecvpn "$@"
  fi
}

start_tinyfecvpn "$@"
