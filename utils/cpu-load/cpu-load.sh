#!/bin/sh

: "${PERCENT_RANGE:=40:60}"
: "${TIME_RANGE:=00:30-06:30}"
: "${ACTIVE_SECONDS:=7200}"

exec cpu-load -p "$PERCENT_RANGE" -t "$TIME_RANGE" -d "$ACTIVE_SECONDS"
