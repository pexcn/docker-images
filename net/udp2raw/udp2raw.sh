#!/bin/sh
# shellcheck disable=SC2155,SC3043

setup_iptables() {
  local symlinks="iptables iptables-save iptables-restore ip6tables ip6tables-save ip6tables-restore"
  local bindir="$(dirname "$(which iptables)")"
  local backend="$(iptables -V | awk -F'[()]' '{print $2}')"
  if [ "$USE_IPTABLES_NFT_BACKEND" = 1 ]; then
    [ "$backend" = "nf_tables" ] || for symlink in ${symlinks}; do ln -sf xtables-nft-multi "${bindir}/${symlink}"; done
  else
    [ "$backend" = "legacy" ] || for symlink in ${symlinks}; do ln -sf xtables-legacy-multi "${bindir}/${symlink}"; done
  fi
}

setup_iptables
if [ "$USE_AES_VARIANT" = 1 ]; then
  exec udp2raw-aes "$@"
else
  exec udp2raw "$@"
fi
