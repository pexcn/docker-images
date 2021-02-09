# shadowsocks-libev for docker

## Usage

```bash
# Available environment variables:
#   SERVER_HOST=0.0.0.0
#   SERVER_PORT=443
#   PASSWORD=FREEHK
#   METHOD=chacha20-ietf-poly1305
#   TIMEOUT=3600
#   NOFILE=65535
#   DNS_SERVERS=8.8.8.8,8.8.4.4
#   MTU=1500
#   ARGS=-v

# ss-server
docker run -d --name ss-server \
  --restart always \
  -p 443:443 \
  -p 443:443/udp \
  -e SERVER_HOST=0.0.0.0 \
  -e SERVER_PORT=443 \
  -e PASSWORD=FREEHK \
  -e METHOD=chacha20-ietf-poly1305 \
  pexcn/docker-images:shadowsocks-libev

# ss-local
docker run -d --name ss-local \
  --restart always \
  -p 1080:1080 \
  -p 1080:1080/udp \
  pexcn/docker-images:shadowsocks-libev \
  ss-local -s 201.90.60.9 -p 443 -l 1080 -k FREEHK -m chacha20-ietf-poly1305 -t 3600 -n 65535 -d 8.8.8.8,8.8.4.4 -u --mtu 1500 --fast-open --reuse-port --no-delay

# ss-redir and ss-tunnel are also used in the same way as ss-local.
```
