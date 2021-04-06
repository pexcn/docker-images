# caddy

## 使用

```bash
docker run -d \
  --name caddy \
  --restart unless-stopped \
  --network host \
  -v /root/docker/caddy/Caddyfile:/etc/caddy/Caddyfile \
  -v /root/docker/acme.sh:/certs \
  -v /etc/localtime:/etc/localtime:ro \
  caddy:2.3.0
```
