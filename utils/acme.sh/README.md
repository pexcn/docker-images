# acme.sh

## Usage

```bash
# Issue
docker exec -it acme.sh --issue --dns dns_he --dnssleep 30 -d local.example.com -d *.local.example.com -k ec-256 -m mail@example.com

# Renew
docker exec -it acme.sh --renew -d local.example.com -d *.local.example.com --ecc --force

# Deploy
docker exec -it acme.sh --deploy --deploy-hook docker -d local.example.com -d *.local.example.com --ecc

# Revoke
docker exec -it acme.sh --revoke -d local.example.com -d *.local.example.com --ecc

# Remove
docker exec -it acme.sh --remove -d local.example.com -d *.local.example.com --ecc
docker exec -it acme.sh rm -r /acme.sh/local.example.com_ecc
```
