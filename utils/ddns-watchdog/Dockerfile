#
# Dockerfile for ddns-watchdog
#

#
# Build stage
#
FROM golang:1.26-alpine AS builder
LABEL maintainer="pexcn <pexcn97@gmail.com>"

ARG VERSION=9fd68bdbf1bcfe3b0247e8251585594183e0bb92
RUN --mount=type=ssh \
  apk add --no-cache --virtual .build-deps openssh-client git make \
  && mkdir -p -m 0700 /root/.ssh && ssh-keyscan github.com >> /root/.ssh/known_hosts \
  && git clone git@github.com:pexcn/ddns-watchdog.git \
  && cd ddns-watchdog \
  && git checkout $VERSION \
  && make \
  && make install \
  && cd - \
  && rm -r ddns-watchdog \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM pexcn/docker-images:alpine
LABEL maintainer="pexcn <pexcn97@gmail.com>"

COPY --from=builder /usr/local/bin/ddns-watchdog /usr/local/bin/

ENV PATH=/usr/local/bin
ENTRYPOINT ["ddns-watchdog"]
