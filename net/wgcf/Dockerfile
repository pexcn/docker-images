#
# Dockerfile for wgcf
#

#
# Build stage
#
FROM golang:alpine AS builder

ARG VERSION=v2.2.8
RUN apk update \
  && apk add --no-cache --virtual .build-deps git \
  && git clone https://github.com/ViRb3/wgcf.git --branch $VERSION \
  && cd wgcf \
  && env CGO_ENABLED=0 go build -v -trimpath -ldflags "-s -w" -o wgcf \
  && install wgcf /usr/local/bin/ \
  && cd .. \
  && rm -r wgcf \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

COPY --from=builder /usr/local/bin/wgcf /usr/local/bin/

WORKDIR /wgcf
ENTRYPOINT ["wgcf"]
