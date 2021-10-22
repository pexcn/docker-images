#
# Dockerfile for strongswan
#

FROM alpine:3.14
LABEL maintainer="pexcn <i@pexcn.me>"

ARG STRONGSWAN_VER=5.9.1-r2
RUN apk update \
  && apk add --no-cache strongswan=$STRONGSWAN_VER

ENV PRE_SHARED_KEY="PSK"
ENV USERS="user:pass,username:password"

COPY entrypoint.sh /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
