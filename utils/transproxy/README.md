# transproxy

## Usage

```sh
docker run -d \
  --name transproxy \
  --restart unless-stopped \
  --network host \
  --privileged \
  -e DISABLE_IPV6=0 \
  -v /lib/modules:/lib/modules:ro \
  -v /etc/localtime:/etc/localtime:ro \
  -v $(pwd)/transproxy-data:/etc/transproxy \
  pexcn/docker-images:transproxy \
    --tcp-port 1234 \
    --src-direct /etc/transproxy/src-direct.txt \
    --dst-direct /etc/transproxy/dst-direct.txt \
    --server 111.222.33.44 \
    --self-proxy
```
