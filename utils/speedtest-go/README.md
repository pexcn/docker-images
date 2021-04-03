# speedtest-go

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
  -e PASSWORD="FREE2501" \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:speedtest-go

docker run -d \
  --name speedtest-go \
  --restart always \
  --network host \
  -e TITLE="NAS Speedtest" \
  -e PORT="8989" \
  -e PASSWORD="FREE2501" \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:speedtest-go
```
