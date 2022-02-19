# webdav

## Usage

```sh
docker run -d \
  --name webdav \
  --restart unless-stopped \
  --network host \
  -e UID=1000 \
  -e GID=1000 \
  -v $(pwd)/webdav-data/config.yml:/etc/webdav/config.yml \
  -v /mnt/data:/data \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:webdav
```
