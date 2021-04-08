# shadowsocks-libev

## Usage

```bash
# ss-server
docker run -d \
  --name ss-server \
  --restart unless-stopped \
  --network host \
  --privileged \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:shadowsocks-libev ss-server \
    -s 0.0.0.0 \
    -p 80 \
    -k password \
    -m aes-256-gcm \
    -t 3600 \
    -n 1048576 \
    -d 8.8.8.8,8.8.4.4 \
    -u \
    --reuse-port \
    --fast-open \
    --no-delay \
    --mtu 1500
# --plugin "obfs-server" --plugin-opts "obfs=tls;fast-open"
# --plugin "v2ray-plugin" --plugin-opts "server;tls;fast-open;mode=websocket;host=example.com"
# --plugin "v2ray-plugin" --plugin-opts "server;tls;fast-open;mode=quic;host=example.com"

# ss-local
docker run -d \
  --name ss-local \
  --restart unless-stopped \
  --network host \
  --privileged \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:shadowsocks-libev ss-local \
    -s 111.222.33.44 \
    -p 80 \
    -b 0.0.0.0 \
    -l 1080 \
    -k password \
    -m aes-256-gcm \
    -t 3600 \
    -n 1048576 \
    -u \
    --reuse-port \
    --fast-open \
    --no-delay \
    --mtu 1500
# --plugin "obfs-local" --plugin-opts "obfs=tls;obfs-host=www.bing.com;fast-open"
# --plugin "v2ray-plugin" --plugin-opts "tls;fast-open;mode=websocket;host=example.com"
# --plugin "v2ray-plugin" --plugin-opts "tls;fast-open;mode=quic;host=example.com"

# ss-redir
docker run -d \
  --name ss-redir \
  --restart unless-stopped \
  --network host \
  --privileged \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:shadowsocks-libev ss-redir \
    -s 111.222.33.44 \
    -p 80 \
    -b 0.0.0.0 \
    -l 1234 \
    -k password \
    -m aes-256-gcm \
    -t 3600 \
    -n 1048576 \
    -u \
    -T \
    --reuse-port \
    --fast-open \
    --no-delay \
    --mtu 1500

# ss-tunnel
docker run -d \
  --name ss-tunnel \
  --restart unless-stopped \
  --network host \
  --privileged \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:shadowsocks-libev ss-tunnel \
    -s 111.222.33.44 \
    -p 80 \
    -b 0.0.0.0 \
    -l 5300 \
    -k password \
    -m aes-256-gcm \
    -t 3600 \
    -n 1048576 \
    -u \
    -L 8.8.8.8:53 \
    --reuse-port \
    --fast-open \
    --no-delay \
    --mtu 1500
```

```bash
# TODO
--tcp-incoming-sndbuf
--tcp-incoming-rcvbuf
--tcp-outgoing-sndbuf
--tcp-outgoing-rcvbuf
```
