# acme.sh

## 使用

```bash
# 签发
docker exec -it acme.sh --issue --dns dns_he --dnssleep 30 -d local.pexcn.me -d *.local.pexcn.me -k ec-256 -m pexcn97@gmail.com

# 续期
docker exec -it acme.sh --renew -d local.pexcn.me -d *.local.pexcn.me --ecc --force

# 部署
docker exec -it acme.sh --deploy --deploy-hook docker -d local.pexcn.me -d *.local.pexcn.me --ecc
```
