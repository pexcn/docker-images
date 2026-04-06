#!/bin/sh

if [ "$#" -eq 0 ]; then
  exec dashboard -c /opt/nezha/dashboard.yml -db /opt/nezha/dashboard.db \
    -loggerLevel WARN \
    -loggerTimezone "${TZ:-Asia/Taipei}" \
    -denyQueryTracing
else
  exec "$@"
fi
