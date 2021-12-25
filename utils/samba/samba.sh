#!/bin/sh
set -e
set -o pipefail

create_user() {
  if [ -n "$USERS" ]; then
    for account in ${USERS//,/ }; do
      local username=$(echo $account | cut -d ':' -f 1)
      local password=$(echo $account | cut -d ':' -f 2)
      adduser -H -D -s /sbin/nologin $username
      printf "%s\n%s\n" $password $password | pdbedit -a $username -f "Samba User" -t
    done
  fi
}

start_samba() {
  exec smbd --foreground --no-process-group
}

create_user
start_samba
