# speedtest-go for docker

## Usage

Available environment variables:
```bash
TITLE
ADDR
PORT
PASSWORD
```

```bash
docker run -d \
  --name speedtest-go \
  --restart always \
  --network host \
  -e TITLE="FREE 2501 Speedtest" \
  -e PORT="80" \
  -e PASSWORD="FREE2501" \
  pexcn/docker-images:speedtest-go

docker run -d \
  --name speedtest-go \
  --restart always \
  --network host \
  -e TITLE="NAS Speedtest" \
  -e ADDR="127.0.0.1" \
  -e PASSWORD="FREE2501" \
  pexcn/docker-images:speedtest-go
```
