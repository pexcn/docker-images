# smartmontools for docker

## Usage

Available environment variables:
```bash
SMARTD_PARAMS
SMTP_CONFIG
```

`SMARTD_PARAMS` is the line of `/etc/smartd.conf`, only one line is supported, example:
```
DEVICESCAN -a -s (S/../../7/13|L/../15/./15) -W 0,0,42 -m pexcn97@gmail.com -M once
```
The meaning of this directives is:
1. Run a **Long Self-Test** on **every 15th** of **every month** at **15 o'clock** and a **Short Self-Test** between **13-14 pm every Sunday**.
2. A warning email will be send if temperatures **reached 42 degrees**.

`SMTP_CONFIG` is the SMTP client config, the format is: `<email>#<user>:<password>@<host>:<port>`.

```bash
# first send a mail test
docker run --rm \
  --name smartmontools \
  --privileged \
  -e "SMARTD_PARAMS=DEVICESCAN -a -m pexcn97@gmail.com -M test" \
  -e "SMTP_CONFIG=who@free.hk#user:freehk@smtp.free.hk:587"
  pexcn/docker-images:smartmontools

# then use it normally
docker run -d \
  --name smartmontools \
  --restart always \
  --privileged \
  -e "SMARTD_PARAMS=DEVICESCAN -a -s (S/../../7/13|L/../15/./15) -W 0,0,42 -m pexcn97@gmail.com -M once" \
  -e "SMTP_CONFIG=who@free.hk#user:freehk@smtp.free.hk:587"
  pexcn/docker-images:smartmontools
```
