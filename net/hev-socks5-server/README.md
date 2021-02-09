# hev-socks5-server for docker

## Usage

```bash
# Available environment variables:
#   PORT=1080
#   LISTEN_ADDRESS='::'
#   DNS_ADDRESS=8.8.8.8
#   IPV6_FIRST=false
#   AUTH=freehk:revolutionnow
#   LOG_LEVEL=warn

docker run -d --name hev-socks5-server \
  --restart always \
  -p 1080:1080 \
  -p 1080:1080/udp \
  pexcn/docker-images:hev-socks5-server
```
