# vlmcsd

## Usage

```bash
docker run -d \
  --name vlmcsd \
  --restart always \
  --network host \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:vlmcsd
```
