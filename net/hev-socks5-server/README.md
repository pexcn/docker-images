# hev-socks5-server

## Usage

Available environment variables:
```bash
PORT
LISTEN_ADDRESS
DNS_ADDRESS
IPV6_FIRST
AUTH
LOG_LEVEL
```

```bash
docker run -d \
  --name hev-socks5-server \
  --restart unless-stopped \
  --network host \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:hev-socks5-server
```
