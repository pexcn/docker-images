# redis

## 使用

调整内核参数
```bash
cat << EOF > /etc/sysctl.d/90-redis.conf
vm.overcommit_memory = 1
EOF
sysctl --system
```

```bash
docker run -d \
  --name redis \
  --restart always \
  --network host \
  -v /mnt/storage/docker/redis:/data \
  -v /etc/localtime:/etc/localtime:ro \
  redis:6.2.0-alpine --bind 127.0.0.1
```
