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
docker run --rm -d \
  --name hev-socks5-server \
  --restart always \
  --net host \
  pexcn/docker-images:hev-socks5-server
```
