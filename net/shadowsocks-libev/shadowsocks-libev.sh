#!/bin/sh

[ "$TFO_COMPAT" != 1 ] || PATH=/srv/bin:$PATH

exec "$@"
