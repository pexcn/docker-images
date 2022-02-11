# shairport-sync

## Usage

```sh
docker run -d \
  --name shairport-sync \
  --restart unless-stopped \
  --network host \
  --device /dev/snd \
  -e AUDIO_GID=996 \
  -v $(pwd)/shairport-sync-data/shairport-sync.conf:/etc/shairport-sync.conf \
  pexcn/docker-images:shairport-sync
```
