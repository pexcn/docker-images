# hev-socks5-server for docker

## Usage

```bash
# Available environment variables:
#   PORT=995
#   LISTEN_ADDRESS=192.168.1.10
#   DNS_ADDRESS=192.168.1.1
#   IPV6_FIRST=true
#   AUTH=freehk:revolutionnow
#   LOG_LEVEL=error

docker run -d --name hev-socks5-server \
  --restart always \
  -p 1080:1080 \
  -p 1080:1080/udp \
  pexcn/docker-images:hev-socks5-server
```
