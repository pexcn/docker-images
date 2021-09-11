#!/bin/sh

build_config() {
  # generate chap-secrets
  if [ -n "$AUTH" ]; then
    for account in "${AUTH//,/ }"; do
      echo "${account%:*}  pptpd  ${account#*:}  *" >> /etc/ppp/chap-secrets
    done
  fi

  # append ms-dns lines?
  #cat /etc/resolv.conf | grep "^nameserver" | awk 'NR<=2 {print "ms-dns", $2}' >> /etc/ppp/pptpd-options
}

setup_firewall() {
  # enable ip forward
  sysctl -w net.ipv4.ip_forward=1

  # configure firewall
  # add INTERFACE environment variable?
  #iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -o $INTERFACE -j MASQUERADE
  iptables -t nat -A POSTROUTING -s 192.168.10.0/24 ! -d 192.168.10.0/24 -j MASQUERADE
  iptables -A INPUT -i ppp+ -j ACCEPT
  iptables -A OUTPUT -o ppp+ -j ACCEPT
  iptables -A FORWARD -i ppp+ -j ACCEPT
  iptables -A FORWARD -o ppp+ -j ACCEPT

  #
  # From archlinux wiki: https://wiki.archlinux.org/index.php/PPTP_server#iptables_firewall_configuration
  #
  ## Accept all packets via ppp* interfaces (for example, ppp0)
  #iptables -A INPUT -i ppp+ -j ACCEPT
  #iptables -A OUTPUT -o ppp+ -j ACCEPT
  ## Accept incoming connections to port 1723 (PPTP)
  #iptables -A INPUT -p tcp --dport 1723 -j ACCEPT
  ## Accept GRE packets
  #iptables -A INPUT -p 47 -j ACCEPT
  #iptables -A OUTPUT -p 47 -j ACCEPT
  ## Enable IP forwarding
  #iptables -F FORWARD
  #iptables -A FORWARD -j ACCEPT
  ## Enable NAT for eth0 on ppp* interfaces
  #iptables -A POSTROUTING -t nat -o eth0 -j MASQUERADE
  #iptables -A POSTROUTING -t nat -o ppp+ -j MASQUERADE

  # fix mtu
  if [ "$FIX_MTU" == 1 ]; then
    iptables -A FORWARD -p tcp --syn -s 192.168.10.0/24 -j TCPMSS --set-mss 1356
    #iptables -A FORWARD -s 192.168.10.0/24 -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j TCPMSS --set-mss 1356
  fi
}

build_config
setup_firewall

exec pptpd -f
