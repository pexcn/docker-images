# netspeeder

## Usage

```bash
# speed up all ip packets
docker run -d \
  --name netspeeder \
  --restart unless-stopped \
  --network host \
  --privileged \
  pexcn/docker-images:netspeeder eth0 "ip"

# speed up port 53 outbound packets and tcp port 1984 outbound packets
docker run -d \
  --name netspeeder \
  --restart unless-stopped \
  --network host \
  --privileged \
  pexcn/docker-images:netspeeder eth0 "src port 53 || tcp src port 1984"
```