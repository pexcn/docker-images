#!/bin/sh
set -e
set -o pipefail

SAMBA_USERS=/etc/samba/users

_is_exist_group() {
  getent group $1 &>/dev/null
}

_is_exist_user() {
  id -u $1 &>/dev/null
}

_trim_lines() {
  sed '/^[[:space:]]*$/d' | sed '/^#/ d'
}

_get_uid() {
  awk -F ':' '{print $1}'
}

_get_username() {
  awk -F ':' '{print $2}'
}

_get_password() {
  awk -F ':' '{print $3}'
}

create_accounts() {
  # system group
  _is_exist_group samba || addgroup -g 1000 samba
  # system user
  cat $SAMBA_USERS | _trim_lines | while read line
  do
    local uid=$(echo $line | _get_uid)
    local username=$(echo $line | _get_username)
    _is_exist_user $username || adduser -D -H -G samba -s /sbin/nologin -u $uid $username
  done

  # samba users
  cat $SAMBA_USERS | _trim_lines | while read line
  do
    local username=$(echo $line | _get_username)
    local password=$(echo $line | _get_password)
    echo -e "$password\n$password" | pdbedit -a $username -f "Samba User" -t
  done
}

start_samba() {
  exec smbd --foreground --no-process-group
}

create_accounts
start_samba
