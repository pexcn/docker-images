#
# Dockerfile for gfw-defense
#

FROM alpine
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add --no-cache iptables ip6tables ipset tzdata \
  && rm -rf /var/cache/apk/*

COPY gfw-defense.sh /usr/local/bin/

ENTRYPOINT ["gfw-defense.sh"]
