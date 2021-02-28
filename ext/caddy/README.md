# caddy

## 使用

```bash
# redirect http to https via 301
cat << EOF > /mnt/storage/docker/caddy/gogs-redirect/Caddyfile
http://git.local.pexcn.me {
  redir https://{host}{uri} permanent
}
EOF
docker run -d \
  --name gogs-redirect \
  --restart always \
  --hostname Caddy \
  --network host \
  -v /mnt/storage/docker/caddy/gogs-redirect/Caddyfile:/etc/caddy/Caddyfile \
  -v /etc/localtime:/etc/localtime:ro \
  caddy:2.3.0
```
