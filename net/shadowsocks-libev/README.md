# shadowsocks-libev

## Usage

Environment variable | Default value | Optional value | Description
:-------------------:|:-------------:|:--------------:|------------
`TFO_COMPAT` | | `1` | Whether to enable TCP Fast Open compatible for old kernel

```bash
# ss-server
docker run -d \
  --name ss-server \
  --restart unless-stopped \
  --network host \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:shadowsocks-libev ss-server \
    -s 0.0.0.0 \
    -p 80 \
    -k password \
    -m aes-256-gcm \
    -t 3600 \
    -n 1048576 \
    -u \
    --reuse-port \
    --fast-open \
    --no-delay
# --plugin "obfs-server" --plugin-opts "obfs=tls;fast-open"
# --plugin "xray-plugin" --plugin-opts "server;tls;fast-open;mode=grpc;host=example.com"

# ss-local
docker run -d \
  --name ss-local \
  --restart unless-stopped \
  --network host \
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
    --no-delay
# --plugin "obfs-local" --plugin-opts "obfs=tls;obfs-host=www.bing.com;fast-open"
# --plugin "xray-plugin" --plugin-opts "tls;fast-open;mode=grpc;host=example.com;loglevel=none;mux=5"

# ss-manager
docker run -d \
  --name ss-manager \
  --restart unless-stopped \
  --network host \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:shadowsocks-libev ss-manager \
    --manager-address 127.0.0.1:6000 \
    -m aes-256-gcm \
    -t 3600 \
    -n 1048576 \
    -u \
    --reuse-port \
    --fast-open \
    --no-delay
```
