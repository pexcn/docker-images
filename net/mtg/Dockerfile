#
# Dockerfile for mtg
#

#
# Build stage
#
FROM golang:alpine AS builder

# build
ARG VERSION=v1.0.7
RUN apk update \
  && apk add --no-cache --virtual .build-deps bash ca-certificates curl git make \
  && git clone https://github.com/9seconds/mtg.git --branch $VERSION /tmp/mtg-src \
  && cd /tmp/mtg-src \
  && make -j$(nproc) static \
  && mv mtg /mtg \
  && make clean \
  && cd / \
  && rm -r /tmp/mtg-src \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

ENV BIND_ADDRESS=0.0.0.0:995
ENV ARGS=
ENV SECRET_KEY=ee3471158e7a53644c047d6b6b8743f8ba62696e672e636f6d

# set timezone
ENV TZ=Asia/Taipei
RUN apk update \
  && apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder /mtg /app/mtg

USER nobody
ENTRYPOINT /app/mtg run -b $BIND_ADDRESS $ARGS $SECRET_KEY
