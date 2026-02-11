#!/bin/sh
# shellcheck disable=SC2155,SC3043,SC3048

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

_remove_rules() {
  eval "$(iptables-save | grep 'tun_fs' | sed 's/-A INPUT/iptables -D INPUT/')"
  info "iptables rules removed."
}

_remove_cnf() {
  ! [ -d /fs/cnf ] || rm -r /fs/cnf
}

_graceful_stop() {
  warn "Caught SIGTERM or SIGINT signal, graceful stopping..."
  _remove_rules
  _remove_cnf
}

_custom_server_port() {
  info "custom server port to ${1}."
  [ -d /fs/cnf ] || mkdir /fs/cnf
  echo "$1" > /fs/cnf/listen_port
}

setup_iptables() {
  local symlinks="iptables iptables-save iptables-restore ip6tables ip6tables-save ip6tables-restore"
  local bindir="$(dirname "$(which iptables)")"
  local backend="$(iptables -V | awk -F'[()]' '{print $2}')"
  if [ "$USE_IPTABLES_NFT_BACKEND" = 1 ]; then
    [ "$backend" = "nf_tables" ] || for symlink in ${symlinks}; do ln -sf xtables-nft-multi "${bindir}/${symlink}"; done
  else
    [ "$backend" = "legacy" ] || for symlink in ${symlinks}; do ln -sf xtables-legacy-multi "${bindir}/${symlink}"; done
  fi
}

start_server() {
  info "start finalspeed server..."
  [ -z "$1" ] || _custom_server_port "$1"
  java "$JAVA_OPTS" -jar /fs/fss.jar &
  wait $!
}

start_client() {
  info "start finalspeed client..."
  xvfb-run -s "-screen 0 320x240x8" java "$JAVA_OPTS" -jar /fs/fsc.jar -b &
  wait $!
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

setup_iptables
main "$@"
