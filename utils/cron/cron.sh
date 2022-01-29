#!/bin/sh
set -e
set -o pipefail

if [ -n "$CRONTAB" ]; then
  echo "$CRONTAB" | crontab -
fi

exec crond -f
#exec crond -f -l 8 -d 8
