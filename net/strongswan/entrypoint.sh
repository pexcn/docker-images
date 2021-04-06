#!/bin/sh

clear_config() {
  > /etc/ipsec.secrets
  > /etc/ipsec.conf
}

gen_ipsec_secrets() {
  [ -n "$PSK" ] && echo "%any %any : PSK \"$PSK\"" >> /etc/ipsec.secrets
}

gen_ipsec_conf() {
  cat <<- EOF >> /etc/ipsec.conf
	config setup
	    uniqueids=no
EOF

  # l2tp-psk
  cat <<- EOF >> /etc/ipsec.conf
	conn l2tp-psk
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

build_config() {
  clear_config
  gen_ipsec_secrets
  gen_ipsec_conf
}

apply_sysctl
build_config

ipsec start
sleep 65535
