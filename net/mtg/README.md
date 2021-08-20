# mtg

## Usage

```bash
docker run -d \
  --name mtg \
  --restart unless-stopped \
  --network host \
  pexcn/docker-images:mtg \
    simple-run 0.0.0.0:990 7kgi5pN2PoUloLUu4FPEVDJ3d3cuYmluZy5jb20 \
    --tcp-buffer=512KB \
    --timeout=30s \
    --prefer-ip=prefer-ipv4 \
    --doh-ip=8.8.8.8
```
