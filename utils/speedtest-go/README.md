# speedtest-go

## Usage

Available environment variables:
```bash
TITLE
ADDR
PORT
```

```bash
docker run -d \
  --name speedtest-go \
  --restart unless-stopped \
  --network host \
  -e TITLE="FREE 2501 Speedtest" \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:speedtest-go

docker run -d \
  --name speedtest-go \
  --restart unless-stopped \
  --network host \
  -e TITLE="NAS Speedtest" \
  -e PORT=8989 \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:speedtest-go
```
