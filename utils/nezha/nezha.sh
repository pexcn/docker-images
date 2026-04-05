#!/bin/sh

exec dashboard \
  -loggerLevel WARN \
  -loggerTimezone "${TZ:-Asia/Taipei}" \
  -denyQueryTracing
