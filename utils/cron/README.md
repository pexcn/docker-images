# cron

## Usage

```sh
docker run -d \
  --name cron \
  --restart unless-stopped \
  --network host \
  -e TZ=Asia/Taipei \
  -e CRONTAB="* * * * * echo test" \
  pexcn/docker-images:cron
```
