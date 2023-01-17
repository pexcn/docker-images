# phantun

## Usage

```sh
# server
phantun-server --local 1985 --remote 127.0.0.1:1985 --ipv4-only \
  --tun phantun-server --tun-local 10.10.100.1 --tun-peer 10.10.100.2

# client
phantun-client --local 127.0.0.1:1985 --remote 11.22.33.44:1985 --ipv4-only \
  --tun phantun-client --tun-local 10.10.100.1 --tun-peer 10.10.100.2
```
