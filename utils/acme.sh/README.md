# acme.sh

## Usage

```bash
# Issue
docker exec -it acme.sh --issue --dns dns_he --dnssleep 30 -d local.pexcn.me -d *.local.pexcn.me -k ec-256 -m pexcn97@gmail.com

# Renew
docker exec -it acme.sh --renew -d local.pexcn.me -d *.local.pexcn.me --ecc --force

# Deploy
docker exec -it acme.sh --deploy --deploy-hook docker -d local.pexcn.me -d *.local.pexcn.me --ecc
```