# udpspeeder

## Usage

```sh
# generic
udpspeeder -s -l 0.0.0.0:2984 -r 127.0.0.1:1984 -f10:6 --timeout 3 --log-level 3 --disable-obscure --disable-checksum
udpspeeder -c -l 127.0.0.1:1984 -r 44.55.66.77:2984 -f10:6 --timeout 3 --log-level 3 --disable-obscure --disable-checksum

# game
udpspeeder -s -l 0.0.0.0:3984 -r 127.0.0.1:1984 -f2:4 --timeout 1 --log-level 3 --disable-obscure --disable-checksum
udpspeeder -c -l 127.0.0.1:1984 -r 44.55.66.77:3984 -f2:4 --timeout 1 --log-level 3 --disable-obscure --disable-checksum
```
