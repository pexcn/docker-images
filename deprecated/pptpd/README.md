# pptpd

## Usage

Available environment variables:
```bash
AUTH
FIX_MTU
```

```bash
docker run -d \
  --name pptpd \
  --restart unless-stopped \
  --network host \
  --privileged \
  -e AUTH="user:pass" \
  -e FIX_MTU=1 \
  pexcn/docker-images:pptpd
```

### Notice

If your container is running on the next level of the router, you MUST forwarding `TCP Port 1723` and `GRE protocol` to use.
