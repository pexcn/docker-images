# acme.sh

## 使用

```bash
docker run -d \
  --name acme.sh \
  --restart unless-stopped \
  --network host \
  -e HE_Username=user \
  -e HE_Password=pass \
  -v /root/docker/acme.sh:/acme.sh \
  -v /etc/localtime:/etc/localtime:ro \
  neilpang/acme.sh:3.0.1 daemon

# issue
docker exec -it acme.sh --issue --dns dns_he --dnssleep 30 -d pexcn.me -d *.pexcn.me -k ec-256 -m pexcn97@gmail.com
docker exec -it acme.sh --issue --dns dns_he --dnssleep 30 -d local.pexcn.me -d *.local.pexcn.me -k ec-256 -m pexcn97@gmail.com

# renew
docker exec -it acme.sh --renew -d pexcn.me -d *.pexcn.me --ecc --force
docker exec -it acme.sh --renew -d local.pexcn.me -d *.local.pexcn.me --ecc --force
```
