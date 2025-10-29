# trojan

## Usage

```bash
# server
docker run -d \
  --name trojan-server \
  --restart unless-stopped \
  --network host \
  -v /root/trojan/server.json:/etc/trojan/config.json \
  -v /root/acme.sh/example.com_ecc/fullchain.cer:/etc/trojan/fullchain.cer \
  -v /root/acme.sh/example.com_ecc/example.com.key:/etc/trojan/private.key \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:trojan

# client
docker run -d \
  --name trojan-client \
  --restart unless-stopped \
  --network host \
  -v /root/trojan/client.json:/etc/trojan/config.json \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:trojan
```
