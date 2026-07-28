#
# Dockerfile for gfw-watchdog
#

#
# Build stage
#
FROM golang:1.26-alpine AS builder
LABEL maintainer="pexcn <pexcn97@gmail.com>"

ARG VERSION=d6fd6acec2248991ce8656c761c6f6bd707fa99b
RUN apk add --no-cache --virtual .build-deps git make \
  && git clone https://github.com/pexcn/gfw-watchdog.git \
  && cd gfw-watchdog \
  && git checkout $VERSION \
  && make \
  && make install \
  && cd - \
  && rm -r gfw-watchdog \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM pexcn/docker-images:scratch
LABEL maintainer="pexcn <pexcn97@gmail.com>"

COPY --from=builder /usr/local/bin/gfw-watchdog /usr/local/bin/
COPY --from=builder /usr/local/bin/echo-server /usr/local/bin/

ENV PATH=/usr/local/bin
ENTRYPOINT ["gfw-watchdog"]
