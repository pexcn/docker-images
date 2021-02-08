# vlmcsd for docker

## Usage

```bash
docker run -d --name vlmcsd \
  --restart always \
  -p 1688:1688 \
  pexcn/docker-images:vlmcsd

-i /etc/vlmcsd/vlmcsd.ini -e -D
```
