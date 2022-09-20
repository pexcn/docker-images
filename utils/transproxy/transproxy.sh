#!/bin/sh

_backup_sysctl() {
  sysctl "$1" >> /tmp/sysctl-origin.conf
}

_restore_sysctl() {
  sysctl -p /tmp/sysctl-origin.conf
  rm /tmp/sysctl-origin.conf
}

_flush_rules() {
  transproxy -f
  [ "$DISABLE_IPV6" = 1 ] || transproxy6 -f
}

graceful_stop() {
  echo "Caught SIGTERM signal, graceful stopping..."
  _flush_rules
  _restore_sysctl
}

setup_sysctl() {
  [ ! -f /tmp/sysctl-origin.conf ] || rm /tmp/sysctl-origin.conf

  _backup_sysctl net.bridge.bridge-nf-call-iptables
  [ "$DISABLE_IPV6" = 1 ] || _backup_sysctl net.bridge.bridge-nf-call-ip6tables

  sysctl -w net.bridge.bridge-nf-call-iptables=0
  [ "$DISABLE_IPV6" = 1 ] || sysctl -w net.bridge.bridge-nf-call-ip6tables=0
}

start_transproxy() {
  trap graceful_stop SIGTERM

  local error=0
  transproxy "$@" || error=1
  [ "$DISABLE_IPV6" = 1 ] || transproxy6 "$@" || error=1
  [ "$error" = 0 ] || { graceful_stop; exit $error; }

  echo "Container started."
  sleep infinity &
  wait
}

setup_sysctl
start_transproxy "$@"
