# shairport-sync

## Usage

```sh
docker run -d \
  --name shairport-sync \
  --restart unless-stopped \
  --network host \
  --device /dev/snd \
  -e AUDIO_GID=996 \
  -e CARD_NUM=1 \
  -v $(pwd)/shairport-sync-data/shairport-sync.conf:/etc/shairport-sync.conf \
  pexcn/docker-images:shairport-sync
```

## Configs

Configs in `shairport-sync.conf` that may need adjustment:
```sh
# general
name
password
interpolation
output_backend

# sessioncontrol
allow_session_interruption

# alsa
output_device
mixer_control_name
output_rate
output_format

# mqtt
# TODO

# diagnostics
log_output_to
log_verbosity
log_show_file_and_line
```
