#!/bin/sh

# shellcheck disable=SC2155,SC3043

# WHITELIST=/etc/gfw-defense/whitelist.txt (some-cidr)
# BLACKLIST=/etc/gfw-defense/blacklist.txt (chnroute exclude some-cidr)

WHITELIST="gfw_defense_whitelist"
BLACKLIST="gfw_defense_blacklist"

load_ipset() {
  ipset create $WHITELIST hash:net hashsize 64 family inet
  ipset create $BLACKLIST hash:net hashsize 64 family inet
}

setup_iptables() {
  # DROP or REJECT
  #BLOCKING_POLICY="DROP"
  # MODE=whitelist -> $BLOCKING_POLICY
  # MODE=blacklist -> RETURN
  #DEFAULT_POLICY="RETURN"

  iptables -N GFW_DEFENSE

  if [ "$BLACKLIST_FIRST" = 1 ]; then
    iptables -A GFW_DEFENSE -m set --match-set $BLACKLIST src -j "$BLOCKING_POLICY"
    iptables -A GFW_DEFENSE -m set --match-set $WHITELIST src -j RETURN
  else
    iptables -A GFW_DEFENSE -m set --match-set $WHITELIST src -j RETURN
    iptables -A GFW_DEFENSE -m set --match-set $BLACKLIST src -j "$BLOCKING_POLICY"
  fi

  iptables -A GFW_DEFENSE -j "$DEFAULT_POLICY"
  iptables -I INPUT -j GFW_DEFENSE
}

start_gfw_defense() {
  load_ipset
  setup_iptables

  # TODO.
}
