# strongswan

## Usage

```bash
docker run -d \
  --name strongswan \
  --restart unless-stopped \
  --privileged \
  -p 500:500/udp \
  -p 4500:4500/udp \
  -e PSK="PreSharedKey" \
  -e USERS="user1:password1,user2:password2" \
  pexcn/docker-images:strongswan
```
