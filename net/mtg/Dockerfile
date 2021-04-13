#
# Dockerfile for mtg
#

#
# Build stage
#
FROM golang:alpine AS builder

# build
ARG VERSION=v1.0.9
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

COPY --from=builder /mtg /app/mtg

# allow bind port less than 1024
RUN apk update \
  && apk add --no-cache libcap \
  && rm -rf /var/cache/apk/*
RUN setcap cap_net_bind_service+ep /app/mtg

EXPOSE 3128 3129
USER nobody
ENTRYPOINT ["/app/mtg"]
