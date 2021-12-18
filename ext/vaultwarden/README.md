# Vaultwarden

## 使用

```sh
docker run -d \
  --name vaultwarden \
  --restart unless-stopped \
  --network host \
  --env-file /root/docker/vaultwarden/config.env \
  -v /etc/localtime:/etc/localtime:ro \
  -v /root/docker/vaultwarden/data:/data \
  vaultwarden/server:1.23.1-alpine
```
