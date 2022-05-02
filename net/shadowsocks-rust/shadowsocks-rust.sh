#!/bin/sh
set -e

if [ "$CHILLING_EFFECT" = 1 ]; then
  exec $(echo "$@" | sed '
    s/ssservice/service/;
    s/ssserver/server/;
    s/sslocal/local/;
    s/ssmanager/manager/;
    s/ssurl/url/;
    s/v2ray-plugin/pv-plugin/;
    s/xray-plugin/px-plugin/;
    s/obfs-server/mix-server/;
    s/obfs-local/mix-local/
  ')
else
  exec "$@"
fi
