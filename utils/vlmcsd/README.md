# vlmcsd

## Usage

```bash
docker run -d \
  --name vlmcsd \
  --restart unless-stopped \
  --network host \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:vlmcsd
```
