#!/bin/sh

info() {
  local green='\e[0;32m'
  local clear='\e[0m'
  local time=$(date '+%Y-%m-%d %T')
  printf "${green}[${time}] [INFO]: ${clear}%s\n" "$*"
}

#lastlog_watcher() {
#}

#graceful_stop() {
#  warn "caught SIGTERM or SIGINT signal, graceful stopping..."
#}

start_motd() {
  while true; do
    echo TODO.
  done

  #inotifyd - /var/log/lastlog:c | while read line; do
  #  local file=$(echo $line | awk '{print $2}')
  #  echo $file changed.
  #done
}

start_motd
