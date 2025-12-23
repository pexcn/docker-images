# smartmontools

## Usage

```bash
# Send a mail test
docker run --rm \
  --name smartmontools \
  --network host \
  --privileged \
  -e TZ="Asia/Taipei" \
  -e SMARTD_CONFIG="DEVICESCAN -a -m pexcn97@gmail.com -M test" \
  -e SMTP_CONFIG="mail@example.com#user:pass@smtp.example.com:587" \
  pexcn/docker-images:smartmontools

# Explanation of SMARTD_CONFIG key parameters:
#   - Short self-test: Triggered at 1:00 AM on the 19th of each month, stagger 1 hour.
#   - Long self-test: Triggered at 06:00 AM on the 5th of each quarter, stagger 6 hours, but not exceeding 18+1 hours.
DEVICESCAN -a -n standby,1440 -s (S/../19/./01:001|L/(01|04|07|10)/05/./06:006-018) -W 0,0,46 -m pexcn97@gmail.com -M diminishing
```
