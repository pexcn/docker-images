# udp2raw

## Recommend parameters

```sh
# server
udp2raw -s -l 0.0.0.0:1501 -r 127.0.0.1:1500 \
  --raw-mode faketcp --cipher-mode none --auth-mode none -a \
  --dev eth0 \
  --log-level 3 \
  --mtu-warn 1375 \
  --hb-mode 0 \
  --wait-lock

# client
udp2raw -c -l 127.0.0.1:1501 -r 111.222.33.44:1501 \
  --raw-mode faketcp --cipher-mode none --auth-mode none -a \
  --dev eth0 \
  --log-level 3 \
  --mtu-warn 1375 \
  --hb-mode 0 \
  --wait-lock
```
