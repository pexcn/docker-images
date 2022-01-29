# cron

## Usage

```sh
docker run -d \
  --name cron \
  --restart unless-stopped \
  --network host \
  -e TZ=Asia/Taipei \
  -e CRONTAB="10 10 * * * /srv/hifini.sh" \
  -v $(pwd)/cron-data:/srv \
  pexcn/docker-images:cron
```
