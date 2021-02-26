# mtg for docker

## Usage

```bash
docker run --rm -d \
  --name mtg \
  --restart always \
  --net host \
  -e BIND_ADDRESS=0.0.0.0:995 \
  -e SECRET_KEY=ee3471158e7a53644c047d6b6b8743f8ba62696e672e636f6d \
  -e ARGS="-w 128KB -r 128KB --prefer-ip=ipv4" \
  pexcn/docker-images:mtg
```
