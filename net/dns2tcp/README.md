# dns2tcp

## Usage

```bash
docker run --rm \
  --name dns2tcp \
  --network host \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:dns2tcp -h

docker run -d \
  --name dns2tcp \
  --restart unless-stopped \
  --network host \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:dns2tcp -L 127.0.0.1#5300 -R 8.8.8.8#53 -r -a -f
```
