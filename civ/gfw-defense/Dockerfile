#
# Dockerfile for gfw-defense
#

FROM alpine
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add --no-cache iptables ip6tables ipset tzdata \
  && rm -rf /var/cache/apk/*

COPY gfw-defense.sh /usr/local/bin/

ENV USE_IPTABLES_NFT_BACKEND=0
ENV BLOCKING_POLICY=DROP
ENV DEFAULT_POLICY=RETURN
ENV QUICK_MODE=0
ENV PREFER_BLACKLIST=0

ENTRYPOINT ["gfw-defense.sh"]
