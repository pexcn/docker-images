# strongswan

## Usage

```bash
docker run -d \
  --name strongswan \
  --restart unless-stopped \
  --privileged \
  -e PSK="psk" \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:strongswan
```
