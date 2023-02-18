#!/bin/sh

# shellcheck disable=SC2155,SC3043

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

_update_rule() {
  local url="$1"
  local file="$(basename "$url")"
  local dir="/etc/chinadns-ng"
  local lines="$(wc -l < "${dir}/${file}")"
  curl -sSL --create-dirs --output-dir $dir -O "$url" || return 1
  info "update ${file}: ${lines} -> $(wc -l < "${dir}/${file}")"
}

update_rules() {
  _update_rule https://github.com/pexcn/daily/raw/gh-pages/chnroute/chnroute.txt || return 1
  _update_rule https://github.com/pexcn/daily/raw/gh-pages/chnroute/chnroute6.txt || return 1
  _update_rule https://github.com/pexcn/daily/raw/gh-pages/gfwlist/gfwlist.txt || return 1
  _update_rule https://github.com/pexcn/daily/raw/gh-pages/chinalist/chinalist.txt || return 1
}

_is_exist_ipset() {
  ipset list -n "$1" >/dev/null 2>&1
}

_destroy_ipset() {
  ipset flush "$1" 2>/dev/null
  ipset destroy "$1" 2>/dev/null
}

create_chnroutes() {
  # TODO: custom ipset name from args
  local ipset4=chnroute
  if _is_exist_ipset $ipset4; then
    ipset flush $ipset4
  else
    ipset create $ipset4 hash:net hashsize 64 family inet
  fi
  ipset restore <<-EOF
	$(sed "s/^/add $ipset4 /" < /etc/chinadns-ng/chnroute.txt)
	EOF

  local ipset6=chnroute6
  if _is_exist_ipset $ipset6; then
    ipset flush $ipset6
  else
    ipset create $ipset6 hash:net hashsize 64 family inet6
  fi
  ipset restore <<- EOF
	$(sed "s/^/add $ipset6 /" < /etc/chinadns-ng/chnroute6.txt)
	EOF
}

stop_process() {
  kill "$(pidof chinadns-ng)"
  info "terminate chinadns-ng processes."

  # ensure child process terminate completely, avoid <defunct> processes
  sleep 5
}

graceful_stop() {
  stop_process
  # TODO: remove chnroutes ipset

  # exit infinite loop
  exit 0
}

start_chinadns_ng() {
  trap 'graceful_stop' TERM INT

  #create_chnroutes

  if [ "$RULES_UPDATE_INTERVAL" = 0 ]; then
    # try replace to: `exec chinadns-ng "$@"`
    # need test `docker stop ...` and `docker-compose up, then ctrl + c`
    chinadns-ng "$@" &
    wait
  else
    chinadns-ng "$@" &
    while true; do
      sleep "$RULES_UPDATE_INTERVAL"
      if update_rules; then
        stop_process
        chinadns-ng "$@" &
      fi
    done
  fi
}

start_chinadns_ng "$@"
