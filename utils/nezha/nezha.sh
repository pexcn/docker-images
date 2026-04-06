#!/bin/sh

if [ "$#" -eq 0 ]; then
  exec dashboard -c /opt/nezha/dashboard.yml \
    -loggerLevel WARN \
    -loggerTimezone "${TZ:-Asia/Taipei}" \
    -denyQueryTracing
else
  exec "$@"
fi
