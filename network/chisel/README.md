# chisel for docker

## Usage

```bash
docker pull pexcn/docker-images:chisel

# server mode
docker run -d pexcn/docker-images:chisel \
  --name chisel \
  --restart always \
  -p 1985:1985 \
  -p 1985:1985/udp \
  server -p 1985 --socks5 --keepalive 10m

# client mode
docker run -d pexcn/docker-images:chisel \
  --name chisel \
  --restart always \
  -p 1985:1985 \
  -p 1985:1985/udp \
  client https://chisel-demo.herokuapp.com 1985 --keepalive 10m
```
