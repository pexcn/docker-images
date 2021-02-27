# gogs for docker

## 使用

首先新建一个名为 `lan` 的 `macvlan` 网络再运行
```bash
# 应用程序版本: 0.13.0+dev
# Git 版本: 2.24.3
# Go 版本: go1.14.7
# 编译时间: 2020-12-13 02:27:53 UTC
# 构建提交: af6510fd17c5cf3d31518dc412bc173e04ec25a1

docker run -d \
  --name gogs \
  --restart always \
  --hostname Git-Server \
  --network lan \
  --ip <ip address> \
  -e "PUID=<git user id>" \
  -e "PGID=<git group id>" \
  -v </path/to/gogs>:/data \
  -v </path/to/certs>:/data/gogs/certs \
  -v /etc/localtime:/etc/localtime:ro \
  gogs/gogs
```
