# mtg

## Usage

```bash
docker run -d \
  --name mtg \
  --restart always \
  --network host \
  -e "BIND_ADDRESS=0.0.0.0:990" \
  -e "SECRET_KEY=ee3471158e7a53644c047d6b6b8743f8ba62696e672e636f6d" \
  -e "ARGS=-w 128KB -r 128KB --prefer-ip=ipv4" \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:mtg
```
