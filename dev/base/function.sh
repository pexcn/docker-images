#!/usr/bin/env bash

_get_time() {
  date '+%Y-%m-%d %T'
}

info() {
  local green='\e[0;32m'
  local clear='\e[0m'
  local time=$(_get_time)
  printf "${green}[${time}] [INFO]: ${clear}%s\n" "$*"
}

warn() {
  local yellow='\e[1;33m'
  local clear='\e[0m'
  local time=$(_get_time)
  printf "${yellow}[${time}] [WARN]: ${clear}%s\n" "$*" >&2
}

error() {
  local red='\e[0;31m'
  local clear='\e[0m'
  local time=$(_get_time)
  printf "${red}[${time}] [ERROR]: ${clear}%s\n" "$*" >&2
}

export -f \
  _get_time \
  info \
  warn \
  error
