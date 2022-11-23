#!/usr/bin/env bash

is_initialized() {
  [ -e /.initialized ]
}

mark_initialized() {
  date +%s > /.initialized
  info "container users initialized."
}

create_user() {
  local username="$1"
  local password=$(echo "$2" | openssl passwd -crypt -stdin)
  local uid=10000
  local gid=10000
  groupadd $username --gid $gid
  useradd $username --uid $uid --gid $gid --shell /bin/bash --password $password --create-home
  cp /root/.* $(eval echo "~$username") 2>/dev/null
}

set_root_password() {
  local password=$(echo "$1" | openssl passwd -crypt -stdin)
  usermod -p $password root
}

append_user_to_docker() {
  local username="$1"
  groupadd docker --gid $DOCKER_GID
  usermod -aG docker $username
}

! is_initialized || { info "container already initialized, skip."; exit 0; }
create_user $USERNAME $PASSWORD
set_root_password $ROOT_PASSWORD
append_user_to_docker $USERNAME
mark_initialized
