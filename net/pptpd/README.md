# pptpd for docker

## Usage

Available environment variables:
```bash
AUTH
FIX_MTU
```

```bash
docker run -d \
  --name pptpd \
  --restart always \
  --network host \
  --privileged \
  -e "AUTH=fuck:china" \
  -e "FIX_MTU=1" \
  pexcn/docker-images:pptpd
```

### Notice

If your container is running on the next level of the router, you MUST forwarding `TCP Port 1723` and `GRE protocol` to use.
