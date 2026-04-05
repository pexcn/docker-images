#!/bin/sh

if [ "$#" -eq 0 ]; then
  exec dashboard -loggerLevel WARN -loggerTimezone "${TZ:-Asia/Taipei}" -denyQueryTracing
else
  exec "$@"
fi
