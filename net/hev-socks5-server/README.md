# hev-socks5-server for docker

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
docker run -d --name hev-socks5-server \
  --restart always \
  -p 1080:1080 \
  -p 1080:1080/udp \
  pexcn/docker-images:hev-socks5-server
```
