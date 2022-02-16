# webdav

## Usage

```sh
# webdav
docker run -d \
  --name webdav \
  --restart unless-stopped \
  --network host \
  -v $(pwd)/webdav-data/config.yml:/etc/webdav/config.yml \
  -v $(pwd)/webdav-data/data:/data \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:webdav
```
