#!/bin/sh
set -e
#set -o pipefail

if [ -n "$CRONTAB" ]; then
  printenv > /etc/environment
  echo "$CRONTAB" | crontab
fi

if [ "$ENABLE_DAEMON" = 1 ]; then
  cron -L 2
  chmod 0600 /etc/rsyncd.secrets
  exec rsync --daemon --no-detach
else
  exec cron -f -L 2
fi
