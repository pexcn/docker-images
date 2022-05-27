#!/bin/sh
set -e

_graceful_stop() {
  echo "Container stopped."
  exit 0
}

start_container() {
  echo "Container started."

  # Cause: /bin/sh -> dash
  # Debian dash shell doesn't recognize SIGTERM signal, use signal number 15 instead.
  trap _graceful_stop 15

  #exec "$@"

  sleep infinity &
  wait
}

start_container
