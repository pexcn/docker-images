# chisel

## Usage

```bash
# server mode
docker run -d \
  --name chisel-server \
  --restart always \
  --network host \
  pexcn/docker-images:chisel server -p 1985 --socks5 --keepalive 10m

# client mode
docker run -d \
  --name chisel-client \
  --restart always \
  --network host \
  pexcn/docker-images:chisel client --keepalive 10m https://chisel-demo.herokuapp.com 1985
```
