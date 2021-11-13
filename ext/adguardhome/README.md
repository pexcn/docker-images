# AdGuardHome

## 使用

```sh
docker run -d \
  --name adguardhome \
  --restart unless-stopped \
  --network host \
  -v /etc/localtime:/etc/localtime:ro \
  -v /root/docker/adguardhome/conf:/opt/adguardhome/conf \
  -v /root/docker/adguardhome/work:/opt/adguardhome/work \
  adguard/adguardhome:v0.106.3
```
