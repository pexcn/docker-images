# smartmontools

## Usage

Available environment variables:
```bash
SMARTD_PARAMS
SMTP_CONFIG
```

`SMARTD_PARAMS` is the line of `/etc/smartd.conf`, only one line is supported, example:
```
DEVICESCAN -a -s (S/../../7/19|L/../15/./20) -W 0,0,45 -m pexcn97@gmail.com -M once
```
The meaning of this directives is:
1. Run a Short Self-Test between 19-20 pm every Sunday.
2. Run a Long Self-Test on every 15th of every month at 20 o'clock.
3. A warning email will be send if temperatures reached 45 degrees.

`SMTP_CONFIG` is the SMTP client config, the format is: `<email>#<user>:<password>@<host>:<port>`.

```bash
# first send a mail test
docker run --rm \
  --name smartmontools \
  --network host \
  --privileged \
  -e SMARTD_PARAMS="DEVICESCAN -a -m pexcn97@gmail.com -M test" \
  -e SMTP_CONFIG="mail@example.com#user:pass@smtp.example.com:587" \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:smartmontools

# then use it normally
docker run -d \
  --name smartmontools \
  --restart unless-stopped \
  --network host \
  --privileged \
  -e SMARTD_PARAMS="DEVICESCAN -a -s (S/../../7/19|L/../15/./20) -W 0,0,45 -m pexcn97@gmail.com -M once" \
  -e SMTP_CONFIG="mail@example.com#user:pass@smtp.example.com:587" \
  -v /etc/localtime:/etc/localtime:ro \
  pexcn/docker-images:smartmontools
```
