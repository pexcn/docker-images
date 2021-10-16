#!/bin/sh

#
# TODO:
# uniqueids: no or never?
#

_clear_config() {
  > /etc/ipsec.secrets
  > /etc/ipsec.conf
}

_gen_ipsec_secrets() {
  [ -n "$PRE_SHARED_KEY" ] && echo "%any %any : PSK \"$PRE_SHARED_KEY\"" >> /etc/ipsec.secrets
}

_gen_ipsec_conf() {
  # common
  cat <<- EOF >> /etc/ipsec.conf
	config setup
	  uniqueids=no
EOF

  # ipsec-xauth-psk
  cat <<- EOF >> /etc/ipsec.conf
	conn ipsec-xauth-psk
	  left=%defaultroute
	  right=%any
	  leftprotoport=17/1701
	  rightprotoport=17/1701
	  authby=secret
	  type=transport
	  dpdaction=clear
	  rekey=no
	  auto=add
EOF
}

apply_sysctl() {
  sysctl -w net.ipv4.ip_forward=1
  sysctl -w net.ipv4.conf.all.accept_redirects=0
  sysctl -w net.ipv4.conf.all.send_redirects=0
}

create_config() {
  _clear_config
  _gen_ipsec_secrets
  _gen_ipsec_conf
}

apply_sysctl
create_config

ipsec start
sleep 65535
