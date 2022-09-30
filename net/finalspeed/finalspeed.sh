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

_clean_up() {
  ! [ -d /fs/cnf ] || { info "clean /fs/cnf directory."; rm -r /fs/cnf; }
}

_graceful_stop() {
  warn "Caught SIGTERM or SIGINT signal, graceful stopping..."
  _clean_up
}

_custom_server_port() {
  info "custom server port to ${1}."
  [ -d /fs/cnf ] || mkdir /fs/cnf
  echo "$1" > /fs/cnf/listen_port
}

start_server() {
  info "start finalspeed server."
  [ -z "$1" ] || _custom_server_port "$1"
  java -jar /fs/fss.jar &
  wait
}

start_client() {
  info "start finalspeed client."
  xvfb-run -s "-screen 0 320x240x8" java -jar /fs/fsc.jar -b &
  wait
}

main() {
  trap _graceful_stop SIGTERM SIGINT

  case "$1" in
    server)
      start_server "$2"
      ;;
    client)
      start_client
      ;;
    *)
      error "unknown option: $1"
      exit 1
      ;;
  esac
}

main "$@"
