# mosquitto

## 使用

```sh
docker run -d \
  --name mosquitto \
  --restart unless-stopped \
  --network host \
  -v $(pwd)/mosquitto-data/config/mosquitto.conf:/mosquitto/config/mosquitto.conf \
  -v $(pwd)/mosquitto-data/data:/mosquitto/data \
  -v $(pwd)/mosquitto-data/log:/mosquitto/log \
  eclipse-mosquitto:2.0.14-openssl
```
