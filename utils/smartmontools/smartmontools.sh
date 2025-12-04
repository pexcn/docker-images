#!/bin/sh
# shellcheck disable=SC2155,SC3043

update_smartd_conf() {
  [ -n "$SMARTD_CONFIG" ] || return
  [ "$SMARTD_CONFIG" != "DEVICESCAN" ] || return
  echo "$SMARTD_CONFIG" > /etc/smartd.conf
}

create_msmtp_conf() {
  local from="${SMTP_CONFIG%%#*}"
  local mid="${SMTP_CONFIG#*#}"

  local auth="${mid%%@*}"
  local user="${auth%%:*}"
  local password="${auth#*:}"

  local addr="${mid#*@}"
  local host="${addr%%:*}"
  local port="${addr#*:}"

  cat <<- EOF > /etc/msmtprc
	defaults
	auth on
	tls on
	tls_trust_file /etc/ssl/certs/ca-certificates.crt
	logfile ~/.msmtp.log

	account mail-provider
	host $host
	port $port
	#tls_starttls off
	from $from
	user $user
	password $password

	account default: mail-provider
	EOF

  # if use ssl via 465 port, must be disable STARTTLS
  # https://wiki.archlinux.org/index.php/Msmtp#Server_sent_empty_reply
  [ "$port" != 465 ] || sed -i '/tls_starttls/s/^#//' /etc/msmtprc

  chmod 600 /etc/msmtprc
}

update_smartd_conf
create_msmtp_conf

exec smartd --no-fork --debug --warnexec /etc/smartd_warning_zh.sh
