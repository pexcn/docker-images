# tinyfecvpn

## Usage

```sh
# generic
tinyfecvpn -s -l 0.0.0.0:1024 \
  --tun-dev tinyfecvpn --sub-net 100.100.100.0 \
  -f10:6 --timeout 3 --log-level 3 --mssfix 0 --disable-obscure --disable-checksum
tinyfecvpn -c -r 44.55.66.77:1024 \
  --tun-dev tinyfecvpn --sub-net 100.100.100.0 --keep-reconnect \
  -f10:6 --timeout 3 --log-level 3 --mssfix 0 --disable-obscure --disable-checksum

# game
tinyfecvpn -s -l 0.0.0.0:2048 \
  --tun-dev tinyfecvpn-game --sub-net 100.100.200.0 \
  -f2:4 --timeout 1 --log-level 3 --mssfix 0 --disable-obscure --disable-checksum
tinyfecvpn -c -r 44.55.66.77:2048 \
  --tun-dev tinyfecvpn-game --sub-net 100.100.200.0 --keep-reconnect \
  -f2:4 --timeout 1 --log-level 3 --mssfix 0 --disable-obscure --disable-checksum
```
