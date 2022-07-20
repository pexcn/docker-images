# gogs

## 使用

确保系统存在 `git` 用户，以保持文件用户组的一致性
```bash
useradd git -m -s $(which git-shell)

docker run -d \
  --name gogs \
  --restart unless-stopped \
  --network host \
  -e PUID="$(id -u git)" \
  -e PGID="$(id -g git)" \
  -e TZ=Asia/Taipei \
  -v /root/docker/gogs-data:/data \
  -v /path/to/git-repos:/data/git/repos \
  gogs/gogs:0.12.9
```

## 配置

### 自定义 Logo

只需要把 logo 放到 `/data/gogs/public/img/favicon.png`

### 反向代理

详见: [@pexcn/docker-images/ext/nginx/nginx-data/conf.d/gogs.conf](https://github.com/pexcn/docker-images/blob/master/ext/nginx/nginx-data/conf.d/gogs.conf)
