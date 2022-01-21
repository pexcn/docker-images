#!/bin/sh
set -e
set -o pipefail

if [ "$AGENT_MODE" = 1 ]; then
  exec nezha-agent "$@"
else
  exec nezha-dashboard
fi
