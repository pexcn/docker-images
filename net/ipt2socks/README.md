# ipt2socks

## Usage

```bash
docker run --rm \
  --name ipt2socks \
  --network host \
  --cap-add NET_ADMIN \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:ipt2socks --help

docker run -d \
  --name ipt2socks \
  --restart unless-stopped \
  --network host \
  --cap-add NET_ADMIN \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:ipt2socks -s 127.0.0.1 -p 1080 -l 1234 -j $(nproc) -r -w -W
```
