#!/bin/sh

ADDR="$1"
SECRET="$2"

if [ -n "$ADDR" ]; then
  sed -i "s/bind-to = \"0.0.0.0:3128\"/bind-to = \"$ADDR\"/" /etc/mtg/config.toml
fi
if [ -n "$SECRET" ]; then
  sed -i "s/secret = \"ee367a189aee18fa31c190054efd4a8e9573746f726167652e676f6f676c65617069732e636f6d\"/secret = \"$SECRET\"/" /etc/mtg/config.toml
fi

exec mtg run /etc/mtg/config.toml