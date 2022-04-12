# wireguard

## Usage

```sh
docker run -d \
  --name wireguard \
  --restart unless-stopped \
  --network host \
  --privileged \
  -v $(pwd)/wireguard-data:/etc/wireguard \
  pexcn/docker-images:wireguard
```

### Commands

```sh
# Generate private/public keys
docker run -it --rm --name wireguard-keygen -v $(pwd)/wg-key:/root/wg-key pexcn/docker-images:wireguard \
  sh -c 'wg genkey | tee /root/wg-key/private.key | wg pubkey > /root/wg-key/public.key'
```

### Templates

```conf
#
# /etc/wireguard/wg-server.conf
#
[Interface]
PrivateKey = <SERVER_PRIVATE_KEY>
Address = 10.10.10.1/32
ListenPort = <SERVER_PORT>

[Peer]
PublicKey = <CLIENT_PUBLIC_KEY>
AllowedIPs = 10.10.10.2/32

#
# /etc/wireguard/wg-client.conf
#
[Interface]
PrivateKey = <CLIENT_PRIVATE_KEY>
Address = 10.10.10.2/32

[Peer]
PublicKey = <SERVER_PUBLIC_KEY>
AllowedIPs = 192.168.1.0/24
Endpoint = <SERVER_ADDR:SERVER_PORT>
PersistentKeepalive = 30
```
