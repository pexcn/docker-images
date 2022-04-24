# WireGuard

## Usage

```sh
docker run -d \
  --name wireguard \
  --restart unless-stopped \
  --network host \
  --privileged \
  -e USE_USERSPACE_MODE=0 \
  -v $(pwd)/wireguard-data:/etc/wireguard \
  pexcn/docker-images:wireguard
```

## Configs

```conf
#
# /etc/wireguard/wg-server.conf
#
[Interface]
PrivateKey = <SERVER_PRIVATE_KEY>
Address = 10.10.10.1/32
ListenPort = <SERVER_PORT>
#DNS = <REMOTE_DNS>
MTU = 1432
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o <INTERFACE> -j SNAT --to-source <INTERFACE_ADDRESS>
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o <INTERFACE> -j SNAT --to-source <INTERFACE_ADDRESS>

[Peer]
PublicKey = <CLIENT_PUBLIC_KEY>
AllowedIPs = 10.10.10.2/32
#Endpoint = <CLIENT_ADDR:CLIENT_PORT>
#PersistentKeepalive = 30

#
# /etc/wireguard/wg-client.conf
#
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.10.10.2/32
#ListenPort = <CLIENT_PORT>
DNS = <REMOTE_DNS>
MTU = 1432
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o <INTERFACE> -j SNAT --to-source <INTERFACE_ADDRESS>
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o <INTERFACE> -j SNAT --to-source <INTERFACE_ADDRESS>

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
AllowedIPs = 10.10.10.1/32, 192.168.1.0/24
Endpoint = <SERVER_ADDR:SERVER_PORT>
PersistentKeepalive = 30
```

## Best Practices

### MTU

The best MTU equals your external MTU minus `60 bytes (IPv4)` or `80 bytes (IPv6)`, e.g.:
```sh
#
# PPPoE MTU: 1492
#
# WireGuard MTU (IPv4): 1492 - 60 = 1432
MTU = 1432

# WireGuard MTU (IPv6): 1492 - 80 = 1412
MTU = 1412
```
See more: https://lists.zx2c4.com/pipermail/wireguard/2017-December/002201.html

### DNS (Unconfirmed)

DNS setting be only when as a client, and should be set to the DNS of remote peer, e.g.:
```sh
DNS = 192.168.1.1
```

### As Gateway

As a gateway, there may be MTU related issues, you can try appending the following iptables rules to `PostUp` and `PostDown`:
```sh
PostUp = ...; iptables -t mangle -A POSTROUTING -o %i -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
PostDown = ...; iptables -t mangle -D POSTROUTING -o %i -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
```
