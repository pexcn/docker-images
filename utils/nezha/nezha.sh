#!/bin/sh

if [ "$#" -eq 0 ]; then
  exec dashboard
else
  exec "$@"
fi
