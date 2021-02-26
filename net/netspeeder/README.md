# netspeeder for docker

## Usage

```bash
docker run --rm -d \
  --name netspeeder \
  --restart always \
  --net host \
  --privileged \
  pexcn/docker-images:netspeeder

# speed up all ip packets
docker run --rm -d \
  --name netspeeder \
  --restart always \
  --net host \
  --privileged \
  pexcn/docker-images:netspeeder eth0 "ip"

# speed up port 53 outbound packets and tcp port 80 outbound packets
docker run --rm -d \
  --name netspeeder \
  --restart always \
  --net host \
  --privileged \
  pexcn/docker-images:netspeeder eth0 "src port 53 || tcp src port 80"
```
