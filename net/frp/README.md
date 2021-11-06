# frp

## Usage

```bash
# frps
docker run -d \
  --name frps \
  --restart unless-stopped \
  --network host \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:frp \
    frps --bind_addr 127.0.0.1 --bind_port 7000 --kcp_bind_port 7000

# frpc
docker run -d \
  --name frpc \
  --restart unless-stopped \
  --network host \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:frp \
    frpc tcp --server_addr 127.0.0.1:7000 --proxy_name ssserver --protocol tcp --uc --local_ip 127.0.0.1 --local_port 2077 --remote_port 2077
```
