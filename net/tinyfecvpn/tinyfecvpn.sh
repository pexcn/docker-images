#!/bin/sh

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
  local time=$(date '+%Y-%m-%d %T')
  printf "${green}[${time}] [INFO]: ${clear}%s\n" "$*"
}

warn() {
  local yellow='\e[1;33m'
  local clear='\e[0m'
  local time=$(date '+%Y-%m-%d %T')
  printf "${yellow}[${time}] [WARN]: ${clear}%s\n" "$*" >&2
}

error() {
  local red='\e[0;31m'
  local clear='\e[0m'
  local time=$(date '+%Y-%m-%d %T')
  printf "${red}[${time}] [ERROR]: ${clear}%s\n" "$*" >&2
}

_get_default_iface() {
  ip -4 route show default | awk -F 'dev' '{print $2}' | awk '{print $1}'
}

_get_addr_by_iface() {
  ip -4 addr show dev "$1" | grep -w "inet" | awk '{print $2}' | awk -F '/' '{print $1}' | head -1
}

_is_server_mode() {
  [ "$1" = "-s" ]
}

_get_tundev_from_args() {
  local tundev=$(echo "$@" | awk -F '--tun-dev' '{print $2}' | awk '{print $1}')
  echo ${tundev:=tinyfecvpn}
}

_get_subnet_from_args() {
  local addr=$(echo "$@" | awk -F '--sub-net' '{print $2}' | awk '{print $1}')
  echo ${addr:=10.22.22.0}
}

_get_port_from_args() {
  echo "$@" | awk -F '-l|-r' '{print $2}' | awk '{print $1}' | awk -F ':' '{print $2}'
}

_check_rule_by_comment() {
  iptables-save | grep -q "$1"
}

apply_sysctl() {
  info "apply sysctl: $(sysctl -w net.ipv4.ip_forward=1)"
}

apply_iptables() {
  local interface=$(_get_default_iface)
  local address=$(_get_addr_by_iface ${interface})
  local tundev=$(_get_tundev_from_args "$@")
  local subnet=$(_get_subnet_from_args "$@")
  local port=$(_get_port_from_args "$@")
  local comment="tinyfecvpn_${tundev}_${port}"

  if _check_rule_by_comment "${comment}"; then
    warn "iptables rules already exist, maybe needs to check."
  else
    info "iptables SNAT rule added: [${comment}]: ${tundev} -> ${interface}, ${subnet} -> ${address}"
    iptables -w 10 -t nat -A POSTROUTING -s "${subnet}/30" -o $interface -j SNAT --to-source $address \
      -m comment --comment "${comment}" || error "iptables SNAT rule add failed, using as a VPN will have issues."
  fi
}

stop_process() {
  kill $(pidof tinyfecvpn)
  info "terminate tinyfecvpn process."
}

revoke_iptables() {
  local tun=$(_get_tundev_from_args "$@")
  local port=$(_get_port_from_args "$@")
  local comment="tinyfecvpn_${tun}_${port}"

  iptables-save -t nat | grep "${comment}" | while read rule; do
    iptables -w 10 -t nat ${rule/-A/-D} || error "iptables nat rule remove failed."
  done
  info "iptables rule: [${comment}] removed."
}

graceful_stop() {
  warn "caught SIGTERM or SIGINT signal, graceful stopping..."
  stop_process
  revoke_iptables "$@"
}

start_tinyfecvpn() {
  if _is_server_mode "$1"; then
    trap 'graceful_stop "$@"' SIGTERM SIGINT
    apply_sysctl
    apply_iptables "$@"
    tinyfecvpn "$@" &
    wait
  else
    exec tinyfecvpn "$@"
  fi
}

start_tinyfecvpn "$@"
