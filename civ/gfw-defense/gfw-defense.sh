#!/bin/sh

# shellcheck disable=SC2155,SC3043

BLOCKING_POLICY="${BLOCKING_POLICY:=DROP}"
PASSING_POLICY="${PASSING_POLICY:=RETURN}"
DEFAULT_POLICY="${DEFAULT_POLICY:=RETURN}"
QUICK_MODE="${QUICK_MODE:=0}"
PREFER_BLACKLIST="${PREFER_BLACKLIST:=0}"
USE_IPTABLES_NFT_BACKEND="${USE_IPTABLES_NFT_BACKEND:=0}"
BLACKLIST_FILES="${BLACKLIST_FILES:=/etc/gfw-defense/blacklist.txt}"
WHITELIST_FILES="${WHITELIST_FILES:=/etc/gfw-defense/whitelist.txt}"
BLACKLIST="gfw_defense_blacklist"
WHITELIST="gfw_defense_whitelist"

# alias ​​settings must be global, and must be defined before the function being called with the alias
if [ "$USE_IPTABLES_NFT_BACKEND" = 1 ]; then
  alias iptables=iptables-nft
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

_is_exist_ipset() {
  ipset list -n "$1" >/dev/null 2>&1
}

_gen_ipset_rules() {
  [ -n "$1" ] || return 0
  [ -n "$2" ] || return 0

  local files="$(echo "$1" | tr ',' ' ')"
  local prefix="$2"
  # FIXME: optimize.
  # shellcheck disable=SC2086
  # splice content
  cat $files |
    # remove empty lines
    sed '/^[[:space:]]*$/d' |
    # remove comment lines
    sed '/^#/d' |
    # trim lines
    awk '{$1=$1};1' |
    # remove duplicates
    awk '!x[$0]++' |
    # insert prefix
    sed "s/^/$prefix/"
}

# TODO: check ipset create params.
load_ipsets() {
  if _is_exist_ipset $BLACKLIST; then
    ipset flush $BLACKLIST
    info "blacklist ipset flushed."
  else
    ipset create $BLACKLIST hash:net hashsize 64 family inet
    info "blacklist ipset created."
  fi
  ipset -exist restore <<-EOF
	$(_gen_ipset_rules "$BLACKLIST_FILES" "add $BLACKLIST ")
	EOF
  info "blacklist loaded into ipset."

  if _is_exist_ipset $WHITELIST; then
    ipset flush $WHITELIST
    info "whitelist ipset flushed."
  else
    ipset create $WHITELIST hash:net hashsize 64 family inet
    info "whitelist ipset created."
  fi
  ipset -exist restore <<-EOF
	$(_gen_ipset_rules "$WHITELIST_FILES" "add $WHITELIST ")
	EOF
  info "whitelist loaded into ipset."
}

_quick_mode() {
  info "use quick mode to match iptables."
  if [ "$PREFER_BLACKLIST" = 1 ]; then
    info "prefer to use blacklist."
    if [ "$DEFAULT_POLICY" != "$BLOCKING_POLICY" ]; then
      iptables -A GFW_DEFENSE -m set --match-set $BLACKLIST src -j "$BLOCKING_POLICY" || error "iptables blacklist rule add failed."
    else
      warn "if the whitelist and blacklist conflict, the blacklist will be invalid."
    fi
    if [ "$DEFAULT_POLICY" != "RETURN" ] && [ "$DEFAULT_POLICY" != "ACCEPT" ]; then
      iptables -A GFW_DEFENSE -m set --match-set $WHITELIST src -j "$PASSING_POLICY" || error "iptables whitelist rule add failed."
    fi
  else
    info "prefer to use whitelist."
    if [ "$DEFAULT_POLICY" != "RETURN" ] && [ "$DEFAULT_POLICY" != "ACCEPT" ]; then
      iptables -A GFW_DEFENSE -m set --match-set $WHITELIST src -j "$PASSING_POLICY" || error "iptables whitelist rule add failed."
    else
      warn "if the whitelist and blacklist conflict, the whitelist will be invalid."
    fi
    if [ "$DEFAULT_POLICY" != "$BLOCKING_POLICY" ]; then
      iptables -A GFW_DEFENSE -m set --match-set $BLACKLIST src -j "$BLOCKING_POLICY" || error "iptables blacklist rule add failed."
    fi
  fi
  return 0
}

_generic_mode() {
  info "use generic mode to match iptables."
  if [ "$PREFER_BLACKLIST" = 1 ]; then
    info "prefer to use blacklist."
    iptables -A GFW_DEFENSE -m set --match-set $BLACKLIST src -j "$BLOCKING_POLICY" || error "iptables blacklist rule add failed."
    iptables -A GFW_DEFENSE -m set --match-set $WHITELIST src -j "$PASSING_POLICY" || error "iptables whitelist rule add failed."
  else
    info "prefer to use whitelist."
    iptables -A GFW_DEFENSE -m set --match-set $WHITELIST src -j "$PASSING_POLICY" || error "iptables whitelist rule add failed."
    iptables -A GFW_DEFENSE -m set --match-set $BLACKLIST src -j "$BLOCKING_POLICY" || error "iptables blacklist rule add failed."
  fi
  return 0
}

apply_iptables() {
  iptables -N GFW_DEFENSE || error "create iptables chain failed."
  iptables -A GFW_DEFENSE -m conntrack --ctstate ESTABLISHED,RELATED -j "$PASSING_POLICY" || error "allowing established connections failed."
  # shellcheck disable=SC2015
  [ "$QUICK_MODE" = 1 ] && _quick_mode || _generic_mode
  iptables -A GFW_DEFENSE -j "$DEFAULT_POLICY" || error "iptables default rule add failed."
  iptables -I INPUT -j GFW_DEFENSE || error "apply iptables chain failed."
  info "iptables rules applied."
}

_revoke_iptables() {
  iptables -D INPUT -j GFW_DEFENSE || error "revoke iptables chain failed."
  iptables -F GFW_DEFENSE || error "iptables rules remove failed."
  iptables -X GFW_DEFENSE || error "iptables chain delete failed."
  info "iptables rules removed."
}

_destroy_ipsets() {
  ipset flush "$BLACKLIST"
  ipset destroy "$BLACKLIST"
  info "blacklist ipset destroyed."
  ipset flush "$WHITELIST"
  ipset destroy "$WHITELIST"
  info "whitelist ipset destroyed."
}

_stop_container() {
  kill "$(jobs -p)"
  info "terminate container."

  # ensure child process terminate completely, avoid <defunct> processes
  sleep 1
}

graceful_stop() {
  warn "caught TERM or INT signal, graceful stopping..."
  _revoke_iptables
  _destroy_ipsets
  _stop_container
  exit 0
}

start_gfw_defense() {
  trap 'graceful_stop' TERM INT

  load_ipsets
  apply_iptables

  info "container started."
  sleep infinity &
  wait
}

start_gfw_defense
