#!/bin/sh
set -e

if ! pgrep rngd >/dev/null; then
  # append `-r /dev/urandom` seems be useful
  rngd
fi

[ "$TFO_COMPAT" == 1 ] && PATH=/app-compat:$PATH

exec "$@"
