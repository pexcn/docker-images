#!/bin/sh

if [[ -n "$SERVER_HOST" && -n "$SERVER_PORT" && -n "$PASSWORD" ]]; then
  if [[ -n "$PLUGIN" ]]; then
    ARGS_EXTRA="--plugin $PLUGIN"
    if [[ -n "$PLUGIN_OPTS" ]]; then
      ARGS_EXTRA="$ARGS_EXTRA --plugin-opts $PLUGIN_OPTS"
    fi
  fi
  if [[ -n "$ARGS_EXTRA" ]]; then
    ARGS="$ARGS_EXTRA $ARGS"
  fi
  exec /app/ss-server \
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
    --no-delay \
    $ARGS
else
  exec /app/"$@"
fi
