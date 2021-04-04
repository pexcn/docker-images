# trojan

## Usage

```bash
# server
docker run -d \
  --name trojan \
  --restart unless-stopped \
  --network host \
  -v /root/trojan/server.json:/app/etc/trojan/config.json \
  -v /root/acme.sh/example.com_ecc/fullchain.cer:/app/etc/fullchain.cer \
  -v /root/acme.sh/example.com_ecc/example.com.key:/app/etc/private.key \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:trojan

# client
docker run -d \
  --name trojan \
  --restart unless-stopped \
  --network host \
  -v /root/trojan/client.json:/app/etc/trojan/config.json \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:trojan
```
