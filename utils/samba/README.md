# Samba

## 使用

```sh
docker run -d \
  --name samba \
  --restart unless-stopped \
  --network host \
  -v $(pwd)/smb.conf:/etc/samba/smb.conf \
  -v $(pwd)/users:/etc/samba/users \
  -v /mnt:/mnt \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:samba
```

## 相关命令

```sh
# 新建用户和组
addgroup -g <gid> <groupname>
adduser -D -H -G <groupname> -s /sbin/nologin -u <uid> <username>

# 新建 Samba 用户
#pdbedit -a <username>
pdbedit -a <username> -f <fullname>
echo -e "<password>\n<password>" | pdbedit -a <username> -f <fullname> -t

# 删除 Samba 用户
pdbedit -x <username>
deluser <username>

# 显示用户详细信息
pdbedit -v <username>

# 显示 Samba 用户列表
pdbedit -L
pdbedit -Lv
```
