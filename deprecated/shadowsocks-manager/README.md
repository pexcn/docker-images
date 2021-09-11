# shadowsocks-manager

## Usage

```bash
# ssmgr-s
docker run -d \
  --name ssmgr-s \
  --restart unless-stopped \
  --network host \
  -v /root/docker/shadowsocks-manager/ssmgr-s:/root/.ssmgr \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:shadowsocks-manager ssmgr -c /root/.ssmgr/ssmgr-s.yml

# ssmgr-m
docker run -d \
  --name ssmgr-m \
  --restart unless-stopped \
  --network host \
  -v /root/docker/shadowsocks-manager/ssmgr-m:/root/.ssmgr \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:shadowsocks-manager ssmgr -c /root/.ssmgr/ssmgr-m.yml
```
