#
# Dockerfile for chisel
#

#
# Build stage
#
FROM golang:alpine AS builder

# depends
RUN apk update \
  && apk add --no-cache --virtual .build-deps git

# build
ARG VERSION=v1.7.6
RUN git clone https://github.com/jpillora/chisel.git --branch $VERSION \
  && cd chisel \
  && go build -ldflags "-X github.com/jpillora/chisel/share.BuildVersion=$VERSION -s -w" -o chisel \
  && mv chisel / \
  && cd .. \
  && rm -r chisel

# clean
RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

COPY --from=builder /chisel /app/

RUN apk update \
  && apk add --no-cache ca-certificates

# allow bind port less than 1024
RUN apk add --no-cache libcap \
  && rm -rf /var/cache/apk/*
RUN setcap cap_net_bind_service+ep /app/chisel

EXPOSE 8080
USER nobody
ENTRYPOINT ["/app/chisel"]
