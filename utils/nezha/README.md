# nezha

## Usage

```sh
# nezha-dashboard
docker run -d \
  --name nezha-dashboard \
  --restart unless-stopped \
  --network host \
  -v $(pwd)/nezha-data:/srv/data \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:nezha

# nezha-agent
docker run -d \
  --name nezha-agent \
  --restart unless-stopped \
  --network host \
  -e AGENT_MODE=1 \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:nezha \
    nezha-agent -s 127.0.0.1:5555 -p <secret> --report-delay 3 --disable-auto-update --disable-force-update --disable-command-execute --skip-procs
```

```sh
# nezha-agent connect with tls
nezha-agent -s status-grpc.example.com:443 -p <secret> --report-delay 3 --disable-auto-update --disable-force-update --disable-command-execute --skip-procs --tls
```
