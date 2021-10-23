#!/bin/sh

set -e

#
# TODO: add ipv6 support
#

_get_ipv4_by_iface() {
  ip addr show dev "$1" | grep -w "inet" | awk '{print $2}' | awk -F '/' '{print $1}' | head -1
}

_get_ipv4_default_iface() {
  #ip -4 route show default | awk '{for (I=1;I<NF;I++) if ($I == "dev") print $(I+1)}'
  ip -4 route show default | awk -F 'dev' '{print $2}' | awk '{print $1}'
}

empty_ipsec_config() {
  > /etc/ipsec.secrets
  > /etc/ipsec.conf
}

gen_ipsec_secrets() {
  # psk
  [ -n "$PSK" ] && echo "%any %any : PSK $PSK" >> /etc/ipsec.secrets

  # users
  if [ -n "$USERS" ]; then
    for account in ${USERS//,/ }; do
      local username=$(echo $account | cut -d ':' -f 1)
      local password=$(echo $account | cut -d ':' -f 2)
      echo "$username : XAUTH $password" >> /etc/ipsec.secrets
    done
  fi
}

gen_ipsec_conf() {
  # common
  cat <<- EOF >> /etc/ipsec.conf
	config setup
	  uniqueids=no
EOF

  # ipsec-xauth-psk
  echo >> /etc/ipsec.conf
  cat <<- EOF >> /etc/ipsec.conf
	conn ipsec-xauth-psk
	  left=%defaultroute
	  leftauth=psk
	  leftauth2=xauth
	  leftsubnet=0.0.0.0/0
	  right=%any
	  rightauth=psk
	  rightauth2=xauth
	  rightsourceip=10.0.0.0/24
	  keyexchange=ikev1
	  ike=aes256-sha256-prfsha256-modp2048,aes256-sha256-prfsha256-modp1024,aes256-sha1-prfsha1-modp2048,aes256-sha1-prfsha1-modp1024,aes256-sha384-prfsha384-modp1024,aes256-sha512-prfsha512-modp1024,aes256-sha512-prfsha512-modp2048
	  authby=secret
	  auto=add
EOF
}

apply_sysctl() {
  sysctl -w net.ipv4.ip_forward=1
}

setup_firewall() {
  local interface=$(_get_ipv4_default_iface)
  local address=$(_get_ipv4_by_iface $interface)

  # SNAT has better performance, also: iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o $interface -j MASQUERADE
  iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o $interface -j SNAT --to-source $address
}

create_config() {
  empty_ipsec_config
  gen_ipsec_secrets
  gen_ipsec_conf
}

start_ipsec() {
  apply_sysctl
  setup_firewall
  exec ipsec start --nofork
}

create_config
start_ipsec
