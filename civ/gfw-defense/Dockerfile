#
# Dockerfile for gfw-defense
#

FROM alpine
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add --no-cache iptables ip6tables ipset tzdata \
  && rm -rf /var/cache/apk/*

RUN mkdir -p /etc/gfw-defense \
  && touch /etc/gfw-defense/blacklist.txt \
  && touch /etc/gfw-defense/whitelist.txt

COPY gfw-defense.sh /usr/local/bin/

ENV BLOCKING_POLICY=DROP
ENV PASSING_POLICY=ACCEPT
ENV DEFAULT_POLICY=RETURN
ENV QUICK_MODE=0
ENV PREFER_BLACKLIST=0
ENV USE_IPTABLES_NFT_BACKEND=0
ENV BLACKLIST_FILES=/etc/gfw-defense/blacklist.txt
ENV WHITELIST_FILES=/etc/gfw-defense/whitelist.txt

ENTRYPOINT ["gfw-defense.sh"]
