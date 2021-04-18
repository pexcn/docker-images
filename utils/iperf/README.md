# iperf

## Usage

```bash
# iperf server
docker run -d \
  --name iperf \
  --restart unless-stopped \
  --network host \
  pexcn/docker-images:iperf -s
```
