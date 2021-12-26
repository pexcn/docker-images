#!/bin/sh
set -e
set -o pipefail

_is_exist_group() {
  id -g $1 &>/dev/null
}

_is_exist_user() {
  id -u $1 &>/dev/null
}

create_group() {
  _is_exist_group samba || addgroup -g 1000 samba
}

create_user() {
  if [ -n "$USERS" ]; then
    for account in ${USERS//,/ }; do
      local username=$(echo $account | cut -d ':' -f 1)
      local password=$(echo $account | cut -d ':' -f 2)
      if ! _is_exist_user $username; then
        adduser -D -H -G samba -s /sbin/nologin $username
        echo -e "$password\n$password" | pdbedit -a $username -f "Samba User" -t
      fi
    done
  fi
}

start_samba() {
  exec smbd --foreground --no-process-group
}

create_group
create_user
start_samba
