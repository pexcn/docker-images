#!/bin/sh

if [[ -n "$SMARTD_CONFIG_PARAMS" && "$SMARTD_CONFIG_PARAMS" != "DEVICESCAN" ]]; then
  echo $SMARTD_CONFIG_PARAMS > /etc/smartd.conf
fi

cat /etc/smartd.conf

#exec /app/smartd --no-fork
