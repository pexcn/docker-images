# Fail2ban

## 使用

```bash
docker run -d \
  --name fail2ban \
  --restart unless-stopped \
  --network host \
  --cap-add NET_ADMIN \
  --cap-add NET_RAW \
  -e TZ=Asia/Taipei \
  -e F2B_LOG_TARGET=/data/fail2ban.log \
  -e F2B_LOG_LEVEL=INFO \
  -e F2B_DB_PURGE_AGE=7d \
  -e SSMTP_HOST=smtp.example.com \
  -e SSMTP_PORT=587 \
  -e SSMTP_USER=user \
  -e SSMTP_PASSWORD=pass \
  -e SSMTP_TLS=yes \
  -e SSMTP_STARTTLS=yes \
  -v /root/docker/fail2ban/data:/data \
  -v /var/log:/var/log:ro \
  crazymax/fail2ban:0.11.2
```
