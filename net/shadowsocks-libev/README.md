# shadowsocks-libev

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
  --restart unless-stopped \
  --network host \
  -e SERVER_HOST=0.0.0.0 \
  -e SERVER_PORT=443 \
  -e PASSWORD=PASSWD \
  -e METHOD=chacha20-ietf-poly1305 \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:shadowsocks-libev

# ss-server with plugin
docker run -d \
  --name ss-server-obfs \
  --restart unless-stopped \
  --network host \
  -e SERVER_HOST=0.0.0.0 \
  -e SERVER_PORT=1776 \
  -e PASSWORD=PASSWD \
  -e METHOD=chacha20-ietf-poly1305 \
  -e PLUGIN="obfs-server" \
  -e PLUGIN_OPTS="obfs=tls;fast-open" \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:shadowsocks-libev

# ss-local
docker run -d \
  --name ss-local \
  --restart unless-stopped \
  --network host \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:shadowsocks-libev \
  ss-local -s 201.90.60.9 -p 443 -b 0.0.0.0 -l 1080 -k PASSWD -m chacha20-ietf-poly1305 -t 3600 -n 65535 -u --mtu 1500 --fast-open --reuse-port --no-delay
```
