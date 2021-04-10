# mtg

## Usage

```bash
docker run -d \
  --name mtg \
  --restart unless-stopped \
  --network host \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:mtg run \
    -b 0.0.0.0:990 \
    -w 128KB \
    -r 128KB \
    --prefer-ip=ipv4 \
    ee3471158e7a53644c047d6b6b8743f8ba62696e672e636f6d
```
