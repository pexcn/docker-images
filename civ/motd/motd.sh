#!/bin/bash

info() {
  local green='\e[0;32m'
  local clear='\e[0m'
  local time=$(date '+%Y-%m-%d %T')
  printf "${green}[${time}] [INFO]: ${clear}%b\n" "$*"
}

warn() {
  local yellow='\e[1;33m'
  local clear='\e[0m'
  local time=$(date '+%Y-%m-%d %T')
  printf "${yellow}[${time}] [WARN]: ${clear}%s\n" "$*" >&2
}

login_callback() {
  # make sure message queue not empty
  if [ ${#queue[@]} = 0 ]; then
    readarray -d '' queue < <(find /srv/messages -maxdepth 1 -type f -print0 | shuf -z)
    [ ${#queue[@]} != 0 ] || { warn "motd message not found. skip."; return; }
    info "motd message queue filled: ${queue[@]}"
  fi

  # motd = header + message
  local message=${queue[0]}
  info "next login will show: $message"
  (
    [ -z "$MESSAGE_HEADER" ] || printf "${MESSAGE_HEADER}\n"
    cat $message <(echo)
  ) > /etc/motd

  # poll element from queue
  queue=("${queue[@]:1}")
}

start_motd() {
  inotifyd - /var/log/lastlog:c | while read line; do
    info "user logged in, trigger callback."
    login_callback
  done
}

start_motd
