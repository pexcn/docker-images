# shadowsocks-rust

## Usage

### Server

```sh
#
# Server mode
#
ssservice server \
  --server-addr 0.0.0.0:80 \
  --password password \
  --encrypt-method aes-128-gcm \
  --timeout 3600 \
  --udp-timeout 300 \
  --user nobody \
  --nofile 1048576 \
  --tcp-keep-alive 300 \
  --tcp-fast-open \
  --tcp-no-delay \
  -U

#
# Plugin options
#
# --plugin "obfs-server" --plugin-opts "obfs=tls;fast-open"
# --plugin "xray-plugin" --plugin-opts "server;tls;fast-open;host=example.com;path=/ws;loglevel=none"
# --plugin "xray-plugin" --plugin-opts "server;tls;fast-open;mode=grpc;host=example.com;loglevel=none"
# --plugin "xray-plugin" --plugin-opts "server;fast-open;mode=quic;host=example.com;loglevel=none"
```

### Client

```sh
#
# Local mode
#
ssservice local \
  #--protocol http \
  --local-addr 0.0.0.0:1080 \
  --server-addr 111.222.33.44:80 \
  --password password \
  --encrypt-method aes-128-gcm \
  --timeout 3600 \
  --udp-timeout 300 \
  --user nobody \
  --nofile 1048576 \
  --tcp-keep-alive 300 \
  --tcp-fast-open \
  --tcp-no-delay \
  -U

#
# Tunnel mode
#
ssservice local \
  --protocol tunnel \
  --local-addr 0.0.0.0:8123 \
  --forward-addr 192.168.1.30:8123 \
  --server-addr 111.222.33.44:2077 \
  --password password \
  --encrypt-method aes-128-gcm \
  --timeout 3600 \
  --udp-timeout 300 \
  --user nobody \
  --nofile 1048576 \
  --tcp-keep-alive 300 \
  --tcp-fast-open \
  --tcp-no-delay \
  -U

#
# Redir mode
#
ssservice local \
  --protocol redir \
  --local-addr 0.0.0.0:1234 \
  --server-addr 111.222.33.44:2077 \
  --password password \
  --encrypt-method aes-128-gcm \
  --timeout 3600 \
  --udp-timeout 300 \
  --user nobody \
  --nofile 1048576 \
  --tcp-keep-alive 300 \
  --tcp-fast-open \
  --tcp-no-delay \
  --tcp-redir tproxy \
  --udp-redir tproxy \
  -U

#
# Plugin options
#
# --plugin "obfs-local" --plugin-opts "obfs=tls;obfs-host=www.bing.com;fast-open"
# --plugin "xray-plugin" --plugin-opts "tls;fast-open;host=example.com;path=/ws?ed=2048;mux=5;loglevel=none"
# --plugin "xray-plugin" --plugin-opts "tls;fast-open;mode=grpc;host=example.com;loglevel=none"
# --plugin "xray-plugin" --plugin-opts "fast-open;mode=quic;host=example.com;loglevel=none"
```

### Others

```sh
#
# Manager mode
#
ssservice manager \
  --manager-address 127.0.0.1:6000 \
  --encrypt-method aes-128-gcm \
  --timeout 3600 \
  --udp-timeout 300 \
  --user nobody \
  --nofile 1048576 \
  --tcp-keep-alive 300 \
  --tcp-fast-open \
  --tcp-no-delay \
  -U
```
