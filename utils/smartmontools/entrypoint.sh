#!/bin/sh

update_smartd_conf() {
  if [[ -n "$SMARTD_PARAMS" && "$SMARTD_PARAMS" != "DEVICESCAN" ]]; then
    echo $SMARTD_PARAMS > /etc/smartd.conf
  fi
}

create_msmtprc() {
  local host=$(echo $SMTP_CONFIG | cut -d '@' -f 3 | cut -d ':' -f 1)
  local port=$(echo $SMTP_CONFIG | cut -d ':' -f 3)
  local from=$(echo $SMTP_CONFIG | cut -d '#' -f 1)
  local user=$(echo $SMTP_CONFIG | cut -d '#' -f 2 | cut -d ':' -f 1)
  local password=$(echo $SMTP_CONFIG | cut -d ':' -f 2 | cut -d '@' -f 1)

  cat <<- EOF > /etc/msmtprc
	defaults
	auth on
	tls on
	#tls_starttls off
	tls_trust_file /etc/ssl/certs/ca-certificates.crt
	logfile ~/.msmtp.log

	account provider
	host $host
	port $port
	from $from
	user $user
	password $password

	account default: provider
	EOF

  # if port equal to 465, must be disable STARTTLS
  # https://wiki.archlinux.org/index.php/Msmtp#Server_sent_empty_reply
  [ "$port" == 465 ] && sed -i '/tls_starttls/s/^#//' /etc/msmtprc

  chmod 600 /etc/msmtprc
}

update_smartd_conf
create_msmtprc

exec /app/smartd --no-fork
