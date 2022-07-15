# AdGuardHome

## 使用

```sh
docker run -d \
  --name adguardhome \
  --restart unless-stopped \
  --network host \
  -e TZ=Asia/Taipei \
  -v /root/docker/adguardhome/conf:/opt/adguardhome/conf \
  -v /root/docker/adguardhome/work:/opt/adguardhome/work \
  adguard/adguardhome:v0.107.8
```
