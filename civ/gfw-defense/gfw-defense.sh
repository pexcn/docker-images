#!/bin/sh

# shellcheck disable=SC2155,SC3043

load_rules() {
  local blacklist="blacklist"
  local whitelist="whitelist"
  ipset create $blacklist hash:net hashsize 64 family inet
  ipset create $whitelist hash:net hashsize 64 family inet
}

todo() {
  WHITELIST="/etc/gfw-defense/whitelist.txt"
  BLACKLIST="/etc/gfw-defense/blacklist.txt"

  # DROP or REJECT
  BLOCKING_POLICY="DROP"
  # MODE=whitelist -> $BLOCKING_POLICY
  # MODE=blacklist -> RETURN
  DEFAULT_POLICY="RETURN"

  iptables -N GFW_DEFENSE
  iptables -A GFW_DEFENSE -m set --match-set $GFW_DEFENSE_WHITELIST src -j RETURN
  iptables -A GFW_DEFENSE -m set --match-set $GFW_DEFENSE_BLACKLIST src -j $BLOCKING_POLICY
  iptables -A GFW_DEFENSE -j $DEFAULT_POLICY
  iptables -I INPUT -j GFW_DEFENSE
}

start_gfw_defense() {
  echo TODO.
}
