# Home Assistant

## 使用

```sh
docker run -d \
  --name home-assistant \
  --restart unless-stopped \
  --network host \
  --privileged \
  -e TZ=Asia/Taipei \
  -v /root/docker/home-assistant:/config \
  homeassistant/home-assistant:2021.9
```
