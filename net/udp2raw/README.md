# udp2raw

## Usage

```sh
docker run -d \
  --name udp2raw \
  --restart unless-stopped \
  --network host \
  --privileged \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:udp2raw <parameters...>
```
