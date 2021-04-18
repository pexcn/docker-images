# iperf3

## Usage

```bash
# iperf3 server
docker run -d \
  --name iperf3 \
  --restart unless-stopped \
  --network host \
  pexcn/docker-images:iperf3 -s
```
