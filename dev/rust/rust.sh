#!/bin/sh
set -e

_graceful_stop() {
  echo "Container stopped."
  exit 0
}

git_global_config() {
  local user=$(git config --global --get user.name)
  local email=$(git config --global --get user.email)
  local non_root_user="vscode"
  if [[ -n "$GIT_USER" && "$GIT_USER" != "$user" ]]; then
    git config --global user.name "$GIT_USER"
    su $non_root_user -c "git config --global user.name $GIT_USER"
  fi
  if [[ -n "$GIT_EMAIL" && "$GIT_EMAIL" != "$email" ]]; then
    git config --global user.email "$GIT_EMAIL"
    su $non_root_user -c "git config --global user.email $GIT_EMAIL"
  fi
}

start_container() {
  echo "Container started."

  # Cause: /bin/sh -> dash
  # Debian dash shell doesn't recognize SIGTERM signal, use signal number 15 instead.
  trap _graceful_stop 15

  # TODO: execute extra commands by arguments
  #"$@"

  sleep infinity &
  wait
}

git_global_config
start_container
