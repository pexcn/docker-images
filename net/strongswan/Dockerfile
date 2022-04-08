#
# Dockerfile for strongswan
#

FROM alpine:3.14
LABEL maintainer="pexcn <i@pexcn.me>"

ARG STRONGSWAN_VER=5.9.1-r2
ARG IPTABLES_VER=1.8.7-r1
ARG IPROUTE2_VER=5.12.0-r0
RUN apk update \
  && apk add --no-cache \
      strongswan=$STRONGSWAN_VER \
      iptables=$IPTABLES_VER \
      iproute2-minimal=$IPROUTE2_VER \
  && rm -rf /var/cache/apk/*

COPY entrypoint.sh /app/entrypoint.sh

ENV PSK=PreSharedKey
ENV USERS=user1:password1,user2:password2
ENV DEBUG=0

EXPOSE 500/udp 4500/udp

ENTRYPOINT ["/app/entrypoint.sh"]
