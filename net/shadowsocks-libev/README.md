# shadowsocks-libev

## Usage

Environment variable | Default value | Optional value | Description
:-------------------:|:-------------:|:--------------:|------------
`TFO_COMPAT` | | `1` | Whether to enable TCP Fast Open compatible for old kernel

### Server

```sh
#
# Server mode
#
ss-server \
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

#
# Plugin options
#
# See net/shadowsocks-rust/README.md
```

### Client

```sh
#
# Local mode
#
ss-local \
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

#
# Plugin options
#
# See net/shadowsocks-rust/README.md
```

### Manager

```sh
#
# Manager mode
#
ss-manager \
  --manager-address 127.0.0.1:6000 \
  -m aes-256-gcm \
  -t 3600 \
  -n 1048576 \
  -u \
  --reuse-port \
  --fast-open \
  --no-delay
```
