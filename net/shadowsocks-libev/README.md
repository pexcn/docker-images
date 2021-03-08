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
PLUGIN
PLUGIN_OPTS
```

```bash
# ss-server
docker run -d \
  --name ss-server \
  --restart always \
  --network host \
  -e "SERVER_HOST=0.0.0.0" \
  -e "SERVER_PORT=443" \
  -e "PASSWORD=FREEHK" \
  -e "METHOD=chacha20-ietf-poly1305" \
  pexcn/docker-images:shadowsocks-libev

# ss-server with plugin
docker run -d \
  --name ss-server-obfs \
  --restart always \
  --network host \
  -e "SERVER_HOST=0.0.0.0" \
  -e "SERVER_PORT=1776" \
  -e "PASSWORD=FREEHK" \
  -e "METHOD=chacha20-ietf-poly1305" \
  -e "PLUGIN=obfs-server" \
  -e "PLUGIN_OPTS=obfs=tls;fast-open" \
  pexcn/docker-images:shadowsocks-libev

# ss-local
docker run -d \
  --name ss-local \
  --restart always \
  --network host \
  pexcn/docker-images:shadowsocks-libev \
  ss-local -s 201.90.60.9 -p 443 -b 0.0.0.0 -l 1080 -k FREEHK -m chacha20-ietf-poly1305 -t 3600 -n 65535 -u --mtu 1500 --fast-open --reuse-port --no-delay
```
