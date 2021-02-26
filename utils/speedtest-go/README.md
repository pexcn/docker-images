# speedtest-go for docker

## Usage

Available environment variables:
```bash
TITLE
PORT
PASSWORD
```

```bash
docker run --rm -d \
  --name speedtest-go \
  --restart always \
  --net host \
  -e TITLE="FREE 2501 Speedtest" \
  -e PASSWORD="FREE2501" \
  pexcn/docker-images:speedtest-go
```
