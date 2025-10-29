# tor

## Usage

```bash
docker run -d \
  --name tor \
  --restart unless-stopped \
  --network host \
  -v /root/tor/torrc:/app/etc/tor/torrc \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:tor
```
