# tinyfecvpn

## Usage

```sh
# generic
# also can try `-f20:10 --timeout 8`
tinyfecvpn -s -l 0.0.0.0:1024 -k password --tun-dev tinyfecvpn-server --sub-net 10.1.1.0 -f10:6 --timeout 3 --log-level 3 --mssfix 0 --disable-obscure --disable-checksum
tinyfecvpn -c -r 11.22.33.44:1024 -k password --tun-dev tinyfecvpn-client --sub-net 10.1.1.0 --keep-reconnect -f10:6 --timeout 3 --log-level 3 --mssfix 0 --disable-obscure --disable-checksum

# game
# also can try `-f2:4 --timeout 0`
tinyfecvpn -s -l 0.0.0.0:2048 -k password --tun-dev tinyfecvpn-server-game --sub-net 10.1.2.0 -f2:4 --timeout 1 --log-level 3 --mssfix 0 --disable-obscure --disable-checksum
tinyfecvpn -c -r 11.22.33.44:2048 -k password --tun-dev tinyfecvpn-client-game --sub-net 10.1.2.0 --keep-reconnect -f2:4 --timeout 1 --log-level 3 --mssfix 0 --disable-obscure --disable-checksum
```
