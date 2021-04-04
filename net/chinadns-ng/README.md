# chinadns-ng

## Usage

```bash
docker run -d \
  --name chinadns-ng \
  --restart unless-stopped \
  --network host \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:chinadns-ng --help
```
