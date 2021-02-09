# shadowsocks-libev for docker

## Usage

Available environment variables:
```bash
SERVER_HOST
SERVER_PORT
PASSWORD
METHOD
TIMEOUT
NOFILE
DNS_SERVERS
MTU
ARGS
```

```bash
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
  ss-local -s 201.90.60.9 -p 443 -b 0.0.0.0 -l 1080 -k FREEHK -m chacha20-ietf-poly1305 -t 3600 -n 65535 -u --mtu 1500 --fast-open --reuse-port --no-delay
```
