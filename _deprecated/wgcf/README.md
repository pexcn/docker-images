# wgcf

## Usage

```bash
# register
MODEL=SERVER
NAME=HOSTNAME
docker run -it --rm \
  --name wgcf \
  --network host \
  -v $(pwd):/wgcf \
  pexcn/docker-images:wgcf register --accept-tos

# generate
docker run -it --rm \
  --name wgcf \
  --network host \
  -v $(pwd):/wgcf \
  pexcn/docker-images:wgcf generate

# update
# Edit wgcf-account.toml
docker run -it --rm \
  --name wgcf \
  --network host \
  -v $(pwd):/wgcf \
  pexcn/docker-images:wgcf update
```
