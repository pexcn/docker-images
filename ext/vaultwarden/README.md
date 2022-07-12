# Vaultwarden

## 使用

```sh
docker run -d \
  --name vaultwarden \
  --restart unless-stopped \
  --network host \
  --env-file $(pwd)/config.env
  -e ROCKET_ENV=production \
  -v $(pwd)/vaultwarden-data:/data \
  -v /etc/localtime:/etc/localtime:ro \
  vaultwarden/server:1.25.0-alpine
```
