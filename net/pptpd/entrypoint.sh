#!/bin/sh

# generate chap-secrets
if [ -n "$AUTH" ]; then
  for account in ${AUTH//,/ }; do
    echo "${account%:*}  pptpd  ${account#*:}  *" >> /etc/ppp/chap-secrets
  done
fi

# configure firewall
sysctl -w net.ipv4.ip_forward=1
#iptables -t nat -A POSTROUTING -o enp4s0 -j MASQUERADE
#iptables -t nat -A POSTROUTING -s 192.168.10.0/24 ! -d 192.168.10.0/24 -j MASQUERADE
#iptables -A INPUT -i ppp+ -j ACCEPT
#iptables -A OUTPUT -o ppp+ -j ACCEPT
#iptables -A INPUT -p tcp --dport 1723 -j ACCEPT
#iptables -A INPUT -p 47 -j ACCEPT
#iptables -A OUTPUT -p 47 -j ACCEPT
#iptables -F FORWARD
#iptables -A FORWARD -j ACCEPT
#iptables -A POSTROUTING -t nat -o enp4s0 -j MASQUERADE
#iptables -A POSTROUTING -t nat -o ppp+ -j MASQUERADE

# fix mtu
if [ "$FIX_MTU" == 1 ]; then
  iptables -A FORWARD -p tcp --syn -s 192.168.10.0/24 -j TCPMSS --set-mss 1356
  #iptables -A FORWARD -s 192.168.10.0/24 -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j TCPMSS --set-mss 1356
fi

exec pptpd -f
