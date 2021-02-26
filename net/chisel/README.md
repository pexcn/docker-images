# chisel for docker

## Usage

```bash
# server mode
docker run --rm -d \
  --name chisel-server \
  --restart always \
  --net host \
  pexcn/docker-images:chisel server -p 1985 --socks5 --keepalive 10m

# client mode
docker run --rm -d \
  --name chisel-client \
  --restart always \
  --net host \
  pexcn/docker-images:chisel client --keepalive 10m https://chisel-demo.herokuapp.com 1985
```
