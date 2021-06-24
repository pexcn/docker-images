# mtg

## Usage

```bash
docker run -d \
  --name mtg \
  --restart unless-stopped \
  --network host \
  -e BIND_TO=0.0.0.0:990 \
  -e SECRET=7kgi5pN2PoUloLUu4FPEVDJ3d3cuYmluZy5jb20 \
  -e TCP_BUFFER=512kb \
  pexcn/docker-images:mtg
```
