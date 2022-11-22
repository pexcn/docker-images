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
  ip addr show dev "$1" | grep -w "inet" | awk '{print $2}' | awk -F '/' '{print $1}' | head -1
}

_is_server_mode() {
  [ "$1" = "-s" ]
}

_get_subnet_from_args() {
  local addr=$(echo "$@" | awk -F '--sub-net' '{print $2}' | awk '{print $1}')
  echo ${addr:=10.22.22.0}
}

_get_tundev_from_args() {
  local tundev=$(echo "$@" | awk -F '--tun-dev' '{print $2}' | awk '{print $1}')
  echo ${tundev:=tinyfecvpn}
}

_check_fw_rule_by_comment() {
  iptables-save | grep -q "$1"
}

apply_sysctl() {
  # if do better, it will have backup and restore logic
  info "apply sysctl: $(sysctl -w net.ipv4.ip_forward=1)"
}

setup_firewall() {
  local interface=$(_get_default_iface)
  local address=$(_get_addr_by_iface $interface)
  local subnet=$(_get_subnet_from_args "$@")
  local tundev=$(_get_tundev_from_args "$@")
  local comment="${tundev}_${subnet}"

  if _check_fw_rule_by_comment "${comment}"; then
    warn "iptables rule already exist, maybe needs to check."
  else
    # like this: https://github.com/pexcn/docker-images/blob/cce4d32/net/strongswan/entrypoint.sh#L119-L121
    info "add iptables rule: [${comment}]: ${tundev} -> ${interface}, ${subnet} -> ${address}"
    iptables -t nat -A POSTROUTING -s ${subnet}/24 -o $interface -j SNAT --to-source $address \
      -m comment --comment "${comment}" || error "iptables add failed, using as a VPN will have issues."
  fi
}

graceful_stop() {
  warn "caught SIGTERM or SIGINT signal, graceful stopping..."

  local subnet=$(_get_subnet_from_args "$@")
  local tundev=$(_get_tundev_from_args "$@")
  local comment="${tundev}_${subnet}"
  iptables-save | grep -v "$comment" | iptables-restore
  info "remove iptables rule: [${comment}]"
}

start_tinyfecvpn() {
  # TODO: caught exit or others... signal?
  # e.g.: pass `--help` argument.
  trap 'graceful_stop "$@"' SIGTERM SIGINT

  if _is_server_mode "$1"; then
    apply_sysctl
    setup_firewall "$@"
    tinyfecvpn "$@"
  else
    exec tinyfecvpn "$@"
  fi
}

start_tinyfecvpn "$@"
