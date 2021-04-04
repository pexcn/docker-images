# chisel

## Usage

```bash
# server
docker run -d \
  --name chisel-server \
  --restart unless-stopped \
  --network host \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:chisel server -p 1985 --socks5 --keepalive 10m

# client
docker run -d \
  --name chisel-client \
  --restart unless-stopped \
  --network host \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:chisel client --keepalive 10m https://chisel-demo.herokuapp.com 1985
```
