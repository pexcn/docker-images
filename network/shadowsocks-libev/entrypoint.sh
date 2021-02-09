#!/bin/sh

exec /app/bin/ss-server \
  -s $SERVER_HOST \
  -p $SERVER_PORT \
  -k $PASSWORD \
  -m $METHOD \
  -t $TIMEOUT \
  -n $NOFILE \
  -d $DNS_SERVERS \
  -u \
  --mtu $MTU \
  --fast-open \
  --reuse-port \
  --no-delay
