# chisel for docker

## Usage

```bash
# server mode
docker run -d --name chisel \
  --restart always \
  -p 1985:1985 \
  -p 1985:1985/udp \
  pexcn/docker-images:chisel server -p 1985 --socks5 --keepalive 10m

# client mode
docker run -d --name chisel \
  --restart always \
  -p 1985:1985 \
  -p 1985:1985/udp \
  pexcn/docker-images:chisel client https://chisel-demo.herokuapp.com 1985 --keepalive 10m
```
