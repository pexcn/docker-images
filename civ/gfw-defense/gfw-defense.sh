#!/bin/sh

# shellcheck disable=SC2155,SC3043

WHITELIST="gfw_defense_whitelist"
BLACKLIST="gfw_defense_blacklist"

load_ipset() {
  ipset create $WHITELIST hash:net hashsize 64 family inet
  ipset create $BLACKLIST hash:net hashsize 64 family inet
}

_quick_mode() {
  if [ "$PREFER_BLACKLIST" = 1 ]; then
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

_common_mode() {
  if [ "$PREFER_BLACKLIST" = 1 ]; then
    iptables -A GFW_DEFENSE -m set --match-set $BLACKLIST src -j "$BLOCKING_POLICY"
    iptables -A GFW_DEFENSE -m set --match-set $WHITELIST src -j RETURN
  else
    iptables -A GFW_DEFENSE -m set --match-set $WHITELIST src -j RETURN
    iptables -A GFW_DEFENSE -m set --match-set $BLACKLIST src -j "$BLOCKING_POLICY"
  fi
}

setup_iptables() {
  iptables -N GFW_DEFENSE
  if [ "$QUICK_MODE" = 1 ]; then
    _quick_mode
  else
    _common_mode
  fi
  iptables -A GFW_DEFENSE -j "$DEFAULT_POLICY"
  iptables -I INPUT -j GFW_DEFENSE
}

start_gfw_defense() {
  load_ipset
  setup_iptables

  # TODO.
}
