#
# Dockerfile for strongswan
#

FROM alpine:3.15
LABEL maintainer="pexcn <i@pexcn.me>"

ARG STRONGSWAN_VER=5.9.1-r4
RUN apk update \
  && apk add --no-cache \
      strongswan=$STRONGSWAN_VER \
      iptables \
      iproute2-minimal \
  && rm -rf /var/cache/apk/*

COPY entrypoint.sh /app/entrypoint.sh

ENV PSK=PreSharedKey
ENV USERS=user1:password1,user2:password2
ENV DEBUG=0

EXPOSE 500/udp 4500/udp

ENTRYPOINT ["/app/entrypoint.sh"]
