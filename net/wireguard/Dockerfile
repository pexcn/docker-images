#
# Dockerfile for wireguard
#

FROM alpine:3.15
LABEL maintainer="pexcn <i@pexcn.me>"

ARG WIREGUARD_VER=1.0.20210914-r0
RUN apk update \
  && apk add --no-cache \
      wireguard-tools=$WIREGUARD_VER \
  && rm -rf /var/cache/apk/*

COPY wireguard.sh /usr/local/bin/

ENTRYPOINT ["wireguard.sh"]
