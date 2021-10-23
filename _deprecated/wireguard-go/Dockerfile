#
# Dockerfile for wireguard-go
#

#
# Build stage
#
FROM golang:1.17-alpine AS builder

ARG VERSION=2ef39d47540c4537f0ddd3355fb95b33b91c09b7
RUN apk update \
  && apk add --no-cache --virtual .build-deps git make \
  && git clone https://git.zx2c4.com/wireguard-go \
  && cd wireguard-go \
  && git checkout $VERSION \
  && sed -i 's/go build -v -o "$@"/env CGO_ENABLED=0 go build -v -o "$@" -trimpath -ldflags "-s -w"/' Makefile \
  && make \
  && make install \
  && cd .. \
  && rm -r wireguard-go \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

COPY --from=builder /usr/bin/wireguard-go /usr/local/bin/

ENTRYPOINT ["wireguard-go"]
