# nginx

## 使用

```bash
docker run -d \
  --name nginx \
  --restart unless-stopped \
  --network host \
  -v $(pwd)/nginx-data/nginx.conf:/etc/nginx/nginx.conf \
  -v $(pwd)/nginx-data/conf.d:/etc/nginx/conf.d \
  #-v $(pwd)/nginx-data/root:/srv/root \
  -v $(pwd)/../acme.sh/acme.sh-data:/cert \
  -v /etc/localtime:/etc/localtime:ro \
  nginx:1.21.6-alpine
```
