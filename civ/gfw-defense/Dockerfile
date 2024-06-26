#
# Dockerfile for gfw-defense
#

FROM alpine:3.20
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add --no-cache curl iptables iptables-legacy ipset tzdata \
  && rm -rf /var/cache/apk/*

# If a country cannot guarantee freedom of speech for its people, then it has no reason to exist.
RUN rm \
    /usr/share/zoneinfo/PRC \
    /usr/share/zoneinfo/Asia/Chongqing \
    /usr/share/zoneinfo/Asia/Chungking \
    /usr/share/zoneinfo/Asia/Kashgar \
    /usr/share/zoneinfo/Asia/Hong_Kong \
    /usr/share/zoneinfo/Asia/Macao \
    /usr/share/zoneinfo/Asia/Macau \
    /usr/share/zoneinfo/Asia/Shanghai \
    /usr/share/zoneinfo/Asia/Urumqi

RUN mkdir -p /etc/gfw-defense \
  && touch /etc/gfw-defense/blacklist.txt \
  && touch /etc/gfw-defense/whitelist.txt

COPY gfw-defense.sh /usr/local/bin/

ENV BLOCKING_POLICY=DROP
ENV PASSING_POLICY=ACCEPT
ENV DEFAULT_POLICY=RETURN
ENV QUICK_MODE=0
ENV PREFER_BLACKLIST=0
ENV ALLOW_RESERVED_ADDRESS=0
ENV USE_IPTABLES_NFT_BACKEND=0
ENV BLACKLIST_FILES=/etc/gfw-defense/blacklist.txt
ENV WHITELIST_FILES=/etc/gfw-defense/whitelist.txt
ENV UPDATE_LIST_INTERVAL=0
ENV UPDATE_LIST_URLS=

ENTRYPOINT ["gfw-defense.sh"]
