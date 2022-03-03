# mosquitto

## 使用

```sh
docker run -d \
  --name mosquitto \
  --restart unless-stopped \
  --network host \
  -v $(pwd)/mosquitto-data/config:/mosquitto/config \
  -v $(pwd)/mosquitto-data/data:/mosquitto/data \
  -v $(pwd)/mosquitto-data/log:/mosquitto/log \
  -v /etc/localtime:/etc/localtime:ro \
  eclipse-mosquitto:2.0.14-openssl
```

## 配置

```sh
# mosquitto.conf 配置项
listener

certfile
keyfile
ciphers
ciphers_tls1.3
cafile ?
```

```sh
# 创建用户
docker exec -it mosquitto mosquitto_passwd -b -c /mosquitto/config/pwfile <username> <password>

# 追加用户
docker exec -it mosquitto mosquitto_passwd -b /mosquitto/config/pwfile <username> <password>

# 删除用户
docker exec -it mosquitto mosquitto_passwd -D /mosquitto/config/pwfile <username>
```
