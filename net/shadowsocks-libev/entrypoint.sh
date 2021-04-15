#!/bin/sh
set -e

[ "$TFO_COMPAT" == 1 ] && PATH=/app-compat:$PATH

exec "$@"
