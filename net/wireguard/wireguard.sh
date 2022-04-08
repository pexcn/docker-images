#!/bin/sh

set -e
set -o pipefail

apply_sysctl() {
  sysctl -w net.ipv4.ip_forward=1
}

# TODO.
