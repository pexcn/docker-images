#!/bin/sh

if [ "$CHILLING_EFFECT" = 1 ]; then
  exec $(echo "$@" | sed '
    s/ssservice/service/;
    s/ssserver/server/;
    s/sslocal/local/;
    s/ssmanager/manager/;
    s/ssurl/url/;
    s/obfs-server/mix-server/;
    s/obfs-local/mix-local/;
    s/v2ray-plugin/pv-plugin/;
    s/xray-plugin/px-plugin/;
    s/qtun-server/qt-server/;
    s/qtun-client/qt-client/
  ')
else
  exec "$@"
fi
