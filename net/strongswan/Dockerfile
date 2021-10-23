#
# Dockerfile for strongswan
#

FROM alpine:3.14
LABEL maintainer="pexcn <i@pexcn.me>"

ARG STRONGSWAN_VER=5.9.1-r2
RUN apk update \
  && apk add --no-cache strongswan=$STRONGSWAN_VER

COPY entrypoint.sh /app/entrypoint.sh

ENV PSK=PreSharedKey
ENV USERS=user1:password1,user2:password2

EXPOSE 500/udp 4500/udp

ENTRYPOINT ["/app/entrypoint.sh"]
