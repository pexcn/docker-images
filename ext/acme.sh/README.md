# acme.sh

## 使用

```bash
docker run -d \
  --name acme.sh \
  --restart unless-stopped \
  --network host \
  -e TZ=Asia/Taipei \
  -e HE_Username=username \
  -e HE_Password=password \
  -v $(pwd)/acme.sh-data:/acme.sh \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  neilpang/acme.sh:3.0.4 daemon

# issue
docker exec -it acme.sh --issue --dns dns_he --dnssleep 30 -d local.pexcn.me -d *.local.pexcn.me -k ec-256 -m pexcn97@gmail.com

# renew
docker exec -it acme.sh --renew -d local.pexcn.me -d *.local.pexcn.me --ecc --force

# deploy
docker exec -it acme.sh --deploy --deploy-hook docker -d local.pexcn.me -d *.local.pexcn.me --ecc
```
