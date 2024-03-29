#!/bin/sh

set -e
set -o pipefail

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

_get_dns_address() {
  local local_dns=$(cat /etc/resolv.conf | grep "^nameserver" | awk '{print $2}' | tr '\n' ',' | sed 's/.$//')
  local fallback_dns="8.8.8.8,8.8.4.4"
  [ -n "$local_dns" ] && echo $local_dns || echo $fallback_dns
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
  local client_ip="10.0.0.0/24"
  local dns_server=$(_get_dns_address)

  # common
  cat <<- EOF >> /etc/ipsec.conf
	config setup
	  uniqueids=no
EOF

  # debug
  [ "$DEBUG" = 1 ] && echo "  charondebug=\"ike 2, cfg 2, net 2\"" >> /etc/ipsec.conf

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
	  rightsourceip=$client_ip
	  rightdns=$dns_server
	  keyexchange=ikev1
	  ike=aes256-sha256-prfsha256-modp2048,aes256-sha256-prfsha256-modp1024,aes256-sha1-prfsha1-modp2048,aes256-sha1-prfsha1-modp1024,aes256-sha384-prfsha384-modp1024,aes256-sha512-prfsha512-modp1024,aes256-sha512-prfsha512-modp2048!
	  esp=aes256-sha256,aes256-sha384,aes256-sha512,aes256-sha1,aes128-sha256,aes128-sha384,aes128-sha512,aes128-sha1!
	  ikelifetime=12h
	  lifetime=4h
	  authby=secret
	  dpdaction=clear
	  dpddelay=60s
	  dpdtimeout=180s
	  auto=add
EOF
}

output_debug_log() {
  local interface=$(_get_ipv4_default_iface)
  local address=$(_get_ipv4_by_iface $interface)
  local dns=$(_get_dns_address)

  echo
  echo "============================== DEBUG LOG START =============================="
  echo
  echo "Interface: $interface"
  echo "IP Address: $address"
  echo "DNS Server: $dns"
  echo
  echo
  echo
  echo "/etc/ipsec.secrets"
  echo
  cat /etc/ipsec.secrets
  echo
  echo
  echo
  echo "/etc/ipsec.conf"
  echo
  cat /etc/ipsec.conf
  echo
  echo "============================== DEBUG LOG END =============================="
  echo
}

apply_sysctl() {
  sysctl -w net.ipv4.ip_forward=1
}

setup_firewall() {
  local interface=$(_get_ipv4_default_iface)
  local address=$(_get_ipv4_by_iface $interface)

  # SNAT has better performance
  # aka: iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o $interface -j MASQUERADE
  iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o $interface -j SNAT --to-source $address
}

create_config() {
  empty_ipsec_config
  gen_ipsec_secrets
  gen_ipsec_conf
}

start_ipsec() {
  [ "$DEBUG" = 1 ] && output_debug_log
  apply_sysctl
  setup_firewall
  exec ipsec start --nofork
}

create_config
start_ipsec
