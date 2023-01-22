# tinyfecvpn

## Usage

```sh
# generic
tinyfecvpn -s -l 0.0.0.0:1024 -k password --tun-dev tinyfecvpn-server --sub-net 10.10.10.0 -f10:5 --timeout 3 --log-level 3 --mssfix 0 --disable-obscure --disable-checksum
tinyfecvpn -c -r 11.22.33.44:1024 -k password --tun-dev tinyfecvpn-client --sub-net 10.10.11.0 --keep-reconnect -f10:5 --timeout 3 --log-level 3 --mssfix 0 --disable-obscure --disable-checksum

# game
tinyfecvpn -s -l 0.0.0.0:2048 -k password --tun-dev tinyfecvpn-server-game --sub-net 10.10.20.0 -f2:4 --timeout 1 --log-level 3 --mssfix 0 --disable-obscure --disable-checksum
tinyfecvpn -c -r 11.22.33.44:2048 -k password --tun-dev tinyfecvpn-client-game --sub-net 10.10.21.0 --keep-reconnect -f2:4 --timeout 1 --log-level 3 --mssfix 0 --disable-obscure --disable-checksum
```
