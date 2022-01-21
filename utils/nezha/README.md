# nezha

## Usage

```bash
# nezha-dashboard
docker run -d \
  --name nezha-dashboard \
  --restart unless-stopped \
  --network host \
  -v $(pwd)/nezha-data:/srv/data \
  pexcn/docker-images:nezha

# nezha-agent
docker run -d \
  --name nezha-agent \
  --restart unless-stopped \
  --network host \
  -e AGENT_MODE=1 \
  pexcn/docker-images:nezha \
    nezha-agent -s 127.0.0.1:8008 -p password --disable-auto-update --disable-force-update --disable-command-execute
```
