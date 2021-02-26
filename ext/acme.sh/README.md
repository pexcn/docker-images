# acme.sh for docker

## 使用

```bash
docker run -d \
  --name acme.sh \
  --restart always \
  --network host \
  -e "HE_Username=user" \
  -e "HE_Password=pass" \
  -v /mnt/storage/docker/acme.sh:/acme.sh \
  neilpang/acme.sh daemon

# issue
docker exec acme.sh --issue --dns dns_he --dnssleep 30 -d pexcn.me -d *.pexcn.me -k ec-256

# renew
docker exec acme.sh --renew -d pexcn.me -d *.pexcn.me --ecc --force
```
