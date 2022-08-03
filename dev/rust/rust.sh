#!/usr/bin/env bash
set -e
set -o pipefail

NON_ROOT_USER="vscode"
NON_ROOT_USER_HOME=$(eval echo "~$NON_ROOT_USER")

_graceful_stop() {
  [ "$ENABLE_SSHD" = 1 ] && service ssh stop

  echo "Container stopped."
  exit 0
}

git_global_config() {
  local user=$(git config --global --get user.name)
  local email=$(git config --global --get user.email)
  if [[ -n "$GIT_USER" && "$GIT_USER" != "$user" ]]; then
    git config --global user.name "$GIT_USER"
    su $NON_ROOT_USER -c "git config --global user.name $GIT_USER"
  fi
  if [[ -n "$GIT_EMAIL" && "$GIT_EMAIL" != "$email" ]]; then
    git config --global user.email "$GIT_EMAIL"
    su $NON_ROOT_USER -c "git config --global user.email $GIT_EMAIL"
  fi
}

ssh_daemon_config() {
  [ "$ENABLE_SSHD" = 1 ] || return 0

  if [[ -n "$SSH_PORT" && "$SSH_PORT" != 22 ]]; then
    if [ ! -f /etc/ssh/sshd_config.d/ssh_port.conf ]; then
      echo "Port $SSH_PORT" > /etc/ssh/sshd_config.d/ssh_port.conf
    fi
  fi

  if [ -f /root/.ssh/authorized_keys ]; then
    if [ ! -f ${NON_ROOT_USER_HOME}/.ssh/authorized_keys ]; then
      mkdir ${NON_ROOT_USER_HOME}/.ssh
      cp /root/.ssh/authorized_keys ${NON_ROOT_USER_HOME}/.ssh/authorized_keys
      chown -R ${NON_ROOT_USER}:${NON_ROOT_USER} ${NON_ROOT_USER_HOME}/.ssh
      chmod 700 ${NON_ROOT_USER_HOME}/.ssh && chmod 600 ${NON_ROOT_USER_HOME}/.ssh/authorized_keys
    fi
  fi

  if [ ! -f /etc/profile.d/env_rust.sh ]; then
    cat <<- EOF > /etc/profile.d/env_rust.sh
	export RUSTUP_HOME=$RUSTUP_HOME \\
	  CARGO_HOME=$CARGO_HOME \\
	  PATH=/usr/local/cargo/bin:\$PATH \\
	  RUST_VERSION=$RUST_VERSION
	EOF
  fi

  service ssh start
}

docker_group_config() {
  [ "$ENABLE_SSHD" = 1 ] || return 0

  if ! getent group docker &>/dev/null; then
    [ -n "$DOCKER_GID" ] && groupadd -g $DOCKER_GID docker || groupadd docker
  fi

  if ! id -nG "$NON_ROOT_USER" | grep -qw "docker"; then
    usermod -aG docker $NON_ROOT_USER
  fi
}

start_container() {
  echo "Container started."

  trap _graceful_stop SIGTERM

  # allow execute extra commands by arguments
  "$@"

  sleep infinity &
  wait
}

git_global_config
ssh_daemon_config
docker_group_config
start_container "$@"
