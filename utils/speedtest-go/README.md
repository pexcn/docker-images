# speedtest-go

## Usage

Environment variable | Default value | Description
---------------------|---------------|------------
`TITLE` | `LibreSpeed` | Web UI title
`ADDR` | all interfaces | Backend bind address
`PORT` | `8989` | Backend bind port

```bash
docker run -d \
  --name speedtest-go \
  --restart unless-stopped \
  --network host \
  -e TITLE="FREE 2501 Speedtest" \
  -e ADDR=127.0.0.1 \
  -e PORT=80 \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:speedtest-go
```
