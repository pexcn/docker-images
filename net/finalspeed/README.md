# FinalSpeed

## Usage

```sh
docker run -d \
  --name finalspeed \
  --restart unless-stopped \
  --network host \
  --privileged \
  --log-opt max-size=10m \
  -e TZ=Asia/Taipei \
  -e JAVA_OPTS="-server -Xmx512m -Xms512m" \
  -v $(pwd)/finalspeed-data/client_config.json:/fs/client_config.json:ro \
  -v $(pwd)/finalspeed-data/port_map.json:/fs/port_map.json:ro \
  pexcn/docker-images:finalspeed [mode] [server_port]
```
