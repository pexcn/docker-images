# UDPSpeeder

## Usage

```sh
docker run -d \
  --name udpspeeder \
  --restart unless-stopped \
  --network host \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:udpspeeder <parameters...>
```

## Recommend parameters

```sh
# Generic
udpspeeder -s -l 0.0.0.0:444 -r 127.0.0.1:443 -f10:6 --timeout 3 --log-level 3 --disable-obscure --disable-checksum
udpspeeder -c -l 127.0.0.1:443 -r 44.55.66.77:444 -f10:6 --timeout 3 --log-level 3 --disable-obscure --disable-checksum

# Game
udpspeeder -s -l 0.0.0.0:444 -r 127.0.0.1:443 -f2:4 --timeout 1 --log-level 3 --disable-obscure --disable-checksum
udpspeeder -c -l 127.0.0.1:443 -r 44.55.66.77:444 -f2:4 --timeout 1 --log-level 3 --disable-obscure --disable-checksum
```
