# iperf & iperf3

## Usage

```bash
# iperf server
docker run -d \
  --name iperf \
  --restart unless-stopped \
  --network host \
  pexcn/docker-images:iperf iperf -s

# iperf3 server
docker run -d \
  --name iperf3 \
  --restart unless-stopped \
  --network host \
  pexcn/docker-images:iperf iperf3 -s
```
