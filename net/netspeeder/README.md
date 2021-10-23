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

# speed up port 993 and 2222 outbound packets
docker run -d \
  --name netspeeder \
  --restart unless-stopped \
  --network host \
  --privileged \
  pexcn/docker-images:netspeeder eth0 "src port 993 || src port 2222"
```
