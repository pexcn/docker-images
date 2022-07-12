# Vaultwarden

## 使用

```sh
docker run -d \
  --name vaultwarden \
  --restart unless-stopped \
  --network host \
  -e ROCKET_ENV=production \
  -v $(pwd)/vaultwarden-data/config.env:/.env \
  -v $(pwd)/vaultwarden-data:/data \
  -v /etc/localtime:/etc/localtime:ro \
  vaultwarden/server:1.25.0-alpine
```
