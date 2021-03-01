# gogs

## 使用

确保系统有一个 `git` 用户，用来保持文件用户组的一致性
```bash
useradd git -m -d /home/git -s $(which git-shell)

docker run -d \
  --name gogs \
  --restart always \
  --network host \
  -e "PUID=$(id -u git)" \
  -e "PGID=$(id -g git)" \
  -v /mnt/storage/docker/gogs:/data \
  -v /mnt/storage/docker/acme.sh:/certs \
  -v /etc/localtime:/etc/localtime:ro \
  gogs/gogs:0.12.3
```

如果需要自定义 logo, 只需要把 logo 放置到 `/data/gogs/public/img/favicon.png`
