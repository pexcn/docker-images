# shadowsocks-rust

## Usage

```bash
# ssserver
docker run -d \
  --name ssserver \
  --restart unless-stopped \
  --network host \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:shadowsocks-rust ssservice server \
    --server-addr 0.0.0.0:80 \
    --password password \
    --encrypt-method aes-128-gcm \
    --timeout 3600 \
    --udp-timeout 300 \
    --udp-max-associations 1024 \
    --nofile 1048576 \
    --tcp-keep-alive 300 \
    --tcp-fast-open \
    --tcp-no-delay \
    -U
# --plugin "obfs-server" --plugin-opts "obfs=tls;fast-open"
# --plugin "xray-plugin" --plugin-opts "server;tls;fast-open;host=example.com;path=/ws"
# --plugin "xray-plugin" --plugin-opts "server;tls;fast-open;mode=grpc;host=example.com"

# sslocal
docker run -d \
  --name sslocal \
  --restart unless-stopped \
  --network host \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:shadowsocks-rust ssservice local \
    --local-addr 0.0.0.0:1080 \
    --server-addr 111.222.33.44:80 \
    --password password \
    --encrypt-method aes-128-gcm \
    --timeout 3600 \
    --udp-timeout 300 \
    --udp-max-associations 1024 \
    --nofile 1048576 \
    --tcp-keep-alive 300 \
    --tcp-fast-open \
    --tcp-no-delay \
    -U
# --dns tcp://127.0.0.1:5300
# --plugin "obfs-local" --plugin-opts "obfs=tls;obfs-host=www.bing.com;fast-open"
# --plugin "xray-plugin" --plugin-opts "tls;fast-open;host=example.com;path=/ws?ed=2048;mux=5;loglevel=none"
# --plugin "xray-plugin" --plugin-opts "tls;fast-open;mode=grpc;host=example.com;loglevel=none"

# sstunnel
docker run -d \
  --name sstunnel \
  --restart unless-stopped \
  --network host \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:shadowsocks-rust ssservice local \
    --protocol tunnel \
    --local-addr 0.0.0.0:8123 \
    --forward-addr 192.168.1.30:8123 \
    --server-addr 111.222.33.44:2077 \
    --password password \
    --encrypt-method aes-128-gcm \
    --timeout 3600 \
    --udp-timeout 300 \
    --udp-max-associations 1024 \
    --nofile 1048576 \
    --tcp-keep-alive 300 \
    --tcp-fast-open \
    --tcp-no-delay \
    -U
# --plugin "obfs-local" --plugin-opts "obfs=tls;obfs-host=www.bing.com;fast-open"
# --plugin "xray-plugin" --plugin-opts "tls;fast-open;host=example.com;path=/ws?ed=2048;mux=5;loglevel=none"
# --plugin "xray-plugin" --plugin-opts "tls;fast-open;mode=grpc;host=example.com;loglevel=none"

# ssmanager
docker run -d \
  --name ssmanager \
  --restart unless-stopped \
  --network host \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:shadowsocks-rust ssservice manager \
    --manager-address 127.0.0.1:6000 \
    --encrypt-method aes-128-gcm \
    --timeout 3600 \
    --udp-timeout 300 \
    --udp-max-associations 1024 \
    --nofile 1048576 \
    --tcp-keep-alive 300 \
    --tcp-fast-open \
    --tcp-no-delay \
    -U
```
