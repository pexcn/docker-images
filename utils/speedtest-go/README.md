# speedtest-go for docker

## Usage

Available environment variables:
```bash
TITLE
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
  pexcn/docker-images:speedtest-go
```
