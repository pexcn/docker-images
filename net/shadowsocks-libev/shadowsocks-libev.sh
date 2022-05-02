#!/bin/sh
set -e

[ "$TFO_COMPAT" = 1 ] && PATH=/srv/bin:$PATH

exec "$@"
