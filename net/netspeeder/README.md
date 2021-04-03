# netspeeder

## Usage

```bash
# speed up all ip packets
docker run -d \
  --name netspeeder \
  --restart always \
  --network host \
  --log-driver none \
  --privileged \
  pexcn/docker-images:netspeeder eth0 "ip" &> /dev/null

# speed up port 53 outbound packets and tcp port 1984 outbound packets
docker run -d \
  --name netspeeder \
  --restart always \
  --network host \
  --log-driver none \
  --privileged \
  pexcn/docker-images:netspeeder eth0 "src port 53 || tcp src port 1984" &> /dev/null
```
