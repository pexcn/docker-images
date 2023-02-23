#!/bin/sh

# shellcheck disable=SC2155,SC3043

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

WHITELIST="gfw_defense_whitelist"
BLACKLIST="gfw_defense_blacklist"

_is_exist_ipset() {
  ipset list -n "$1" >/dev/null 2>&1
}

# TODO: check ipset create params.
load_ipsets() {
  if _is_exist_ipset $WHITELIST; then
    ipset flush $WHITELIST
    info "whitelist ipset flushed."
  else
    ipset create $WHITELIST hash:net hashsize 64 family inet
    info "whitelist ipset created."
  fi
  ipset restore <<-EOF
	$(sed "s/^/add $WHITELIST /" </etc/gfw-defense/whitelist.txt)
	EOF
  info "whitelist loaded into ipset."

  if _is_exist_ipset $BLACKLIST; then
    ipset flush $BLACKLIST
    info "blacklist ipset flushed."
  else
    ipset create $BLACKLIST hash:net hashsize 64 family inet
    info "blacklist ipset created."
  fi
  ipset restore <<-EOF
	$(sed "s/^/add $BLACKLIST /" </etc/gfw-defense/blacklist.txt)
	EOF
  info "blacklist loaded into ipset."
}

_quick_mode() {
  if [ "$PREFER_BLACKLIST" = 1 ]; then
    info "prefer to use blacklist."
    if [ "$DEFAULT_POLICY" != "$BLOCKING_POLICY" ]; then
      iptables -A GFW_DEFENSE -m set --match-set $BLACKLIST src -j "$BLOCKING_POLICY"
    fi
    if [ "$DEFAULT_POLICY" != "RETURN" ] && [ "$DEFAULT_POLICY" != "ACCEPT" ]; then
      iptables -A GFW_DEFENSE -m set --match-set $WHITELIST src -j RETURN
    fi
  else
    if [ "$DEFAULT_POLICY" != "RETURN" ] && [ "$DEFAULT_POLICY" != "ACCEPT" ]; then
      iptables -A GFW_DEFENSE -m set --match-set $WHITELIST src -j RETURN
    fi
    if [ "$DEFAULT_POLICY" != "$BLOCKING_POLICY" ]; then
      iptables -A GFW_DEFENSE -m set --match-set $BLACKLIST src -j "$BLOCKING_POLICY"
    fi
  fi
}

_generic_mode() {
  if [ "$PREFER_BLACKLIST" = 1 ]; then
    info "prefer to use blacklist."
    iptables -A GFW_DEFENSE -m set --match-set $BLACKLIST src -j "$BLOCKING_POLICY"
    iptables -A GFW_DEFENSE -m set --match-set $WHITELIST src -j RETURN
  else
    info "prefer to use whitelist."
    iptables -A GFW_DEFENSE -m set --match-set $WHITELIST src -j RETURN
    iptables -A GFW_DEFENSE -m set --match-set $BLACKLIST src -j "$BLOCKING_POLICY"
  fi
}

setup_iptables() {
  iptables -N GFW_DEFENSE
  if [ "$QUICK_MODE" = 1 ]; then
    info "use quick mode to match iptables."
    warn "xxx may be invalid.?"
    _quick_mode
  else
    info "use generic mode to match iptables."
    _generic_mode
  fi
  iptables -A GFW_DEFENSE -j "$DEFAULT_POLICY"
  iptables -I INPUT -j GFW_DEFENSE
}

start_gfw_defense() {
  load_ipsets
  setup_iptables

  # TODO.
}
