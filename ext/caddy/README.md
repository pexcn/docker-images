# caddy

## 使用

```bash
docker run -d \
  --name caddy \
  --restart always \
  --network host \
  -v /mnt/storage/docker/caddy/Caddyfile:/etc/caddy/Caddyfile \
  -v /mnt/storage/docker/acme.sh:/certs \
  -v /etc/localtime:/etc/localtime:ro \
  caddy:2.3.0
```
