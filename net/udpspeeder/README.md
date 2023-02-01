# udpspeeder

## Usage

```sh
# generic
# also can try `-f20:10 --timeout 8`
udpspeeder -s -l 0.0.0.0:1985 -r 127.0.0.1:1984 -f10:6 --timeout 3 --log-level 3 --disable-obscure --disable-checksum
udpspeeder -c -l 127.0.0.1:1984 -r 11.22.33.44:1985 -f10:6 --timeout 3 --log-level 3 --disable-obscure --disable-checksum

# game
# also can try `-f2:4 --timeout 0`
udpspeeder -s -l 0.0.0.0:1986 -r 127.0.0.1:1984 -f2:4 --timeout 1 --log-level 3 --disable-obscure --disable-checksum
udpspeeder -c -l 127.0.0.1:1984 -r 11.22.33.44:1986 -f2:4 --timeout 1 --log-level 3 --disable-obscure --disable-checksum
```
