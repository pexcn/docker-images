#
# Dockerfile for mtg
#

#
# Build stage
#
FROM golang:1.26-alpine AS builder

ARG VERSION=v2.2.3
RUN apk add --no-cache --virtual .build-deps git \
  && git clone https://github.com/9seconds/mtg.git --branch $VERSION \
  && cd mtg \
  && env CGO_ENABLED=0 go build \
      -v \
      -trimpath \
      -mod=readonly \
      -ldflags="-X main.version=$VERSION -s -w -buildid=" \
      -tags netgo \
  && install mtg /usr/local/bin/ \
  && cd - \
  && rm -r mtg \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine:3.23
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder /usr/local/bin/mtg /usr/local/bin/

# allow bind port less than 1024
RUN apk add --no-cache libcap \
  && rm -rf /var/cache/apk/*
RUN setcap cap_net_bind_service+ep /usr/local/bin/mtg

USER nobody
ENTRYPOINT ["mtg"]
CMD ["--help"]
