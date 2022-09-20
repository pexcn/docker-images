# transproxy

## Usage

```sh
docker run -d \
  --name transproxy \
  --restart unless-stopped \
  --network host \
  --privileged \
  -v /lib/modules:/lib/modules:ro \
  pexcn/docker-images:transproxy
```
