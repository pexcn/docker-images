# rsync

## Usage

```sh
docker run -d \
  --name rsync \
  --restart unless-stopped \
  --network host \
  -e ENABLE_DAEMON=1 \
  -e CRONTAB="0 */12 * * * /srv/backup.sh >/proc/1/fd/1" \
  -e TZ=Asia/Taipei \
  -v $(pwd)/rsync-data/rsyncd.conf:/etc/rsyncd.conf \
  -v $(pwd)/rsync-data/rsyncd.secrets:/etc/rsyncd.secrets \
  -v $(pwd)/rsync-data/backup.sh:/srv/backup.sh \
  -v /mnt/disk/backup:/mnt/disk/backup \
  pexcn/docker-images:rsync
```
