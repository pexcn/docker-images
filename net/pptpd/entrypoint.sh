#!/bin/sh

# generate chap-secrets
if [ -n "$AUTH" ]; then
  for account in ${AUTH//,/ }; do
    echo "${account%:*}  pptpd  ${account#*:}  *" >> /etc/ppp/chap-secrets
  done
fi

# iptables setting
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# fix mtu
[ "$FIX_MTU" == 1 ] && iptables -A FORWARD -p tcp --syn -s 192.168.10.0/24 -j TCPMSS --set-mss 1356

exec pptpd -f
