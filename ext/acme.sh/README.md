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
  neilpang/acme.sh:2.9.0 daemon

# issue
docker exec -it acme.sh --issue --dns dns_he --dnssleep 30 -d pexcn.me -d *.pexcn.me -k ec-256
docker exec -it acme.sh --issue --dns dns_he --dnssleep 30 -d local.pexcn.me -d *.local.pexcn.me -k ec-256

# renew
docker exec -it acme.sh --renew -d pexcn.me -d *.pexcn.me --ecc --force
docker exec -it acme.sh --renew -d local.pexcn.me -d *.local.pexcn.me --ecc --force
```
