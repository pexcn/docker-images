# shadowsocks-rust

## Usage

```bash
# ssserver
docker run -d \
  --name ssserver \
  --restart unless-stopped \
  --network host \
  --privileged \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:shadowsocks-rust ssserver \
    --server-addr 0.0.0.0:80 \
    --password password \
    --encrypt-method aes-128-gcm \
    --dns udp://8.8.8.8,8.8.4.4 \
    --timeout 3600 \
    --udp-timeout 300 \
    --udp-max-associations 512 \
    --nofile 1048576 \
    --no-delay \
    -U
# --plugin "v2ray-plugin" --plugin-opts "server;tls;fast-open;mode=websocket;host=example.com"
# --plugin "v2ray-plugin" --plugin-opts "server;tls;fast-open;mode=quic;host=example.com"
# --plugin "xray-plugin" --plugin-opts "server;tls;fast-open;mode=websocket;host=example.com"
# --plugin "xray-plugin" --plugin-opts "server;tls;fast-open;mode=quic;host=example.com"

# sslocal
docker run -d \
  --name sslocal \
  --restart unless-stopped \
  --network host \
  --privileged \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:shadowsocks-rust sslocal \
    --local-addr 0.0.0.0:1080 \
    --server-addr 111.222.33.44:80 \
    --password password \
    --encrypt-method aes-128-gcm \
    --timeout 3600 \
    --udp-timeout 300 \
    --udp-max-associations 512 \
    --nofile 1048576 \
    --no-delay \
    -U
# --protocol http
# --dns tcp://127.0.0.1:5300
# --plugin "v2ray-plugin" --plugin-opts "tls;fast-open;mode=websocket;host=example.com"
# --plugin "v2ray-plugin" --plugin-opts "tls;fast-open;mode=quic;host=example.com"
# --plugin "xray-plugin" --plugin-opts "tls;fast-open;mode=websocket;host=example.com"
# --plugin "xray-plugin" --plugin-opts "tls;fast-open;mode=quic;host=example.com"

# ssredir
docker run -d \
  --name ssredir \
  --restart unless-stopped \
  --network host \
  --privileged \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:shadowsocks-rust sslocal \
    --protocol redir \
    --tcp-redir tproxy \
    --udp-redir tproxy \
    --local-addr 0.0.0.0:1234 \
    --server-addr 111.222.33.44:80 \
    --password password \
    --encrypt-method aes-128-gcm \
    --timeout 3600 \
    --udp-timeout 300 \
    --udp-max-associations 512 \
    --nofile 1048576 \
    --no-delay \
    -U
# --dns tcp://127.0.0.1:5300

# sstunnel
docker run -d \
  --name sstunnel \
  --restart unless-stopped \
  --network host \
  --privileged \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:shadowsocks-rust sslocal \
    --protocol tunnel \
    --forward-addr 8.8.8.8:53 \
    --local-addr 0.0.0.0:5300 \
    --server-addr 111.222.33.44:80 \
    --password password \
    --encrypt-method aes-128-gcm \
    --timeout 3600 \
    --udp-timeout 300 \
    --udp-max-associations 512 \
    --nofile 1048576 \
    --no-delay \
    -U
```

```bash
# TODO
--inbound-recv-buffer-size
--inbound-send-buffer-size
--outbound-recv-buffer-size
--outbound-send-buffer-size
--outbound-fwmark
--worker-threads
```
