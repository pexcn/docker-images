#!/bin/sh

if [[ -n "$TITLE" && "$TITLE" != "LibreSpeed Example" ]]; then
  sed -i "s/<title>LibreSpeed Example<\/title>/<title>$TITLE<\/title>/" /app/assets/index.html
  sed -i "s/<h1>LibreSpeed Example<\/h1>/<h1>$TITLE<\/h1>/" /app/assets/index.html
fi

if [[ -n "$PORT" && "$PORT" != 8989 ]]; then
  sed -i "s/listen_port=8989/listen_port=$PORT/" /app/settings.toml
fi

if [[ -n "$PASSWORD" && "$PASSWORD" != "PASSWORD" ]]; then
  sed -i "s/statistics_password=\"PASSWORD\"/statistics_password=\"$PASSWORD\"/" /app/settings.toml
fi

cd /app
exec /app/speedtest-go