# FinalSpeed

## Usage

```sh
docker run -d \
  --name finalspeed \
  --restart unless-stopped \
  --network host \
  -e TZ=Asia/Taipei \
  -v $(pwd)/finalspeed-data/client_config.json:/fs/client_config.json \
  -v $(pwd)/finalspeed-data/port_map.json:/fs/port_map.json \
  pexcn/docker-images:finalspeed [mode] [server_port]
```
