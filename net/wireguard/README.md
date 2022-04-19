# wireguard

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
#MTU = 1420
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o <INTERFACE> -j SNAT --to-source <INTERFACE_ADDRESS>
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o <INTERFACE> -j SNAT --to-source <INTERFACE_ADDRESS>

[Peer]
PublicKey = <CLIENT_PUBLIC_KEY>
AllowedIPs = 10.10.10.0/24

#
# /etc/wireguard/wg-client.conf
#
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.10.10.2/32
DNS = <REMOTE_DNS>
#MTU = 1420

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
AllowedIPs = 10.10.10.0/24, 192.168.1.0/24
Endpoint = <SERVER_ADDR:SERVER_PORT>
PersistentKeepalive = 30
```
