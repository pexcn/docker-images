#!/bin/sh
set -e
set -o pipefail

create_user() {
  if [ -n "$USERS" ]; then
    for account in ${USERS//,/ }; do
      local username=$(echo $account | cut -d ':' -f 1)
      local password=$(echo $account | cut -d ':' -f 2)
      adduser -D -H -s /sbin/nologin $username
      echo -e "$password\n$password" | pdbedit -a $username -f "Samba User" -t
    done
  fi
}

start_samba() {
  exec smbd --foreground --no-process-group
}

create_user
start_samba
