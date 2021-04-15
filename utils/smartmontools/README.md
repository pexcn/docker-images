# smartmontools

## Usage

Environment variable | Default value | Description
---------------------|---------------|------------
`SMARTD_CONFIG` | `DEVICESCAN` | Configuration line in `/etc/smartd.conf`, only one line is supported
`SMTP_CONFIG` | `mail@example.com#user:pass@smtp.example.com:587` | SMTP client config, format: `<email>#<user>:<password>@<host>:<port>`

```bash
# Send a mail test at first
docker run --rm \
  --name smartmontools \
  --network host \
  --privileged \
  -e SMARTD_CONFIG="DEVICESCAN -a -m pexcn97@gmail.com -M test" \
  -e SMTP_CONFIG="mail@example.com#user:pass@smtp.example.com:587" \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:smartmontools

# Then use it normally, the meaning of SMARTD_CONFIG is:
#   1. run a Short Self-Test between 19-20 pm every Sunday.
#   2. run a Long Self-Test on every 15th of every month at 20 o'clock.
#   3. a warning email will be send if temperatures reached 45 degrees.
docker run -d \
  --name smartmontools \
  --restart unless-stopped \
  --network host \
  --privileged \
  -e SMARTD_CONFIG="DEVICESCAN -a -s (S/../../7/19|L/../15/./20) -W 0,0,45 -m pexcn97@gmail.com -M once" \
  -e SMTP_CONFIG="mail@example.com#user:pass@smtp.example.com:587" \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:smartmontools
```
