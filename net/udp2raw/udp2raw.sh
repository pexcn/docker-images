#!/bin/sh

# shellcheck disable=SC2155,SC3043

setup_iptables() {
  local symlinks="iptables iptables-save iptables-restore ip6tables ip6tables-save ip6tables-restore"
  local bindir="$(dirname "$(which iptables)")"
  if [ "$USE_IPTABLES_NFT_BACKEND" = 1 ]; then
    for symlink in ${symlinks}; do ln -sf xtables-nft-multi "${bindir}/${symlink}"; done
  else
    for symlink in ${symlinks}; do ln -sf xtables-legacy-multi "${bindir}/${symlink}"; done
  fi
}

setup_iptables
exec udp2raw "$@"
