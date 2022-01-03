# rsync

## Usage

```sh
docker run -d \
  --name rsync \
  --restart unless-stopped \
  --network host \
  -e TZ=Asia/Taipei \
  -v $(pwd)/rsyncd.conf:/etc/rsyncd.conf \
  -v $(pwd)/rsyncd.secrets:/etc/rsyncd.secrets \
  -v /mnt/disk/backup:/mnt/disk/backup \
  pexcn/docker-images:rsync
```
