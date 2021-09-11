# caddy

## 使用

```bash
docker run -d \
  --name caddy \
  --restart unless-stopped \
  --network host \
  -v /root/docker/caddy-data/Caddyfile:/etc/caddy/Caddyfile \
  -v /root/docker/acme.sh-data:/certs \
  -v /etc/localtime:/etc/localtime:ro \
  caddy:2.4.5
```
