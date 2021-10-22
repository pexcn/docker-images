#!/bin/sh

#
# TODO:
# uniqueids: no or never?
#

_clear_config() {
  > /etc/ipsec.secrets
  > /etc/ipsec.conf
}

_gen_secrets() {
  # psk
  [ -n "$PSK" ] && echo "%any %any : PSK $PSK" >> /etc/ipsec.secrets

  # users
  if [ -n "$USERS" ]; then
    for account in "${USERS//,/ }"; do
      local username=$(echo $account | cut -d ':' -f 1)
      local password=$(echo $account | cut -d ':' -f 2)
      echo "$username : XAUTH $password" >> /etc/ipsec.secrets
    done
  fi
}

_gen_conf() {
  # common
  cat <<- EOF >> /etc/ipsec.conf
	config setup
	  uniqueids=no

EOF

  # ipsec-xauth-psk
  cat <<- EOF >> /etc/ipsec.conf
	conn ipsec-xauth-psk
	  left=%defaultroute
	  leftauth=psk
	  leftauth2=xauth
	  leftsubnet=0.0.0.0/0
	  right=%any
	  rightauth=psk
	  rightauth2=xauth
	  rightsourceip=192.168.100.0/24
	  keyexchange=ikev1
	  ike=aes256-sha256-prfsha256-modp2048,aes256-sha256-prfsha256-modp1024,aes256-sha1-prfsha1-modp2048,aes256-sha1-prfsha1-modp1024,aes256-sha384-prfsha384-modp1024,aes256-sha512-prfsha512-modp1024,aes256-sha512-prfsha512-modp2048
	  authby=secret
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
  _gen_secrets
  _gen_conf
}

#apply_sysctl
create_config

ipsec start --nofork
