#!/bin/sh
set -e
set -o pipefail

echo
echo "[$(date '+%Y-%m-%d %T')] HiFiNi Auto Sign In Starting."

RANDOM_DELAY=$(echo $((RANDOM % 600)))
sleep $RANDOM_DELAY

COOKIES="bbs_sid=xxxxxxxxxxxxxxxxxxxxxxxxxxx; bbs_token=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

curl 'https://www.hifini.com/sg_sign.htm' \
  -X 'POST' \
  -H 'authority: www.hifini.com' \
  -H 'content-length: 0' \
  -H 'pragma: no-cache' \
  -H 'cache-control: no-cache' \
  -H 'sec-ch-ua: " Not;A Brand";v="99", "Google Chrome";v="97", "Chromium";v="97"' \
  -H 'accept: text/plain, */*; q=0.01' \
  -H 'x-requested-with: XMLHttpRequest' \
  -H 'sec-ch-ua-mobile: ?0' \
  -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.99 Safari/537.36' \
  -H 'sec-ch-ua-platform: "Windows"' \
  -H 'origin: https://www.hifini.com' \
  -H 'sec-fetch-site: same-origin' \
  -H 'sec-fetch-mode: cors' \
  -H 'sec-fetch-dest: empty' \
  -H 'referer: https://www.hifini.com/sg_sign.htm' \
  -H 'accept-language: zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7' \
  -H "cookie: $COOKIES" \
  --compressed \
  -s -S -w '\n'

echo "[$(date '+%Y-%m-%d %T')] HiFiNi Auto Sign In Finished."
echo
