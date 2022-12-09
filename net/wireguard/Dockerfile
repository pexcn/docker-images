#
# Dockerfile for wireguard
#

#
# Build stage
#
FROM rust:alpine AS builder

ARG VERSION=boringtun-0.5.2
RUN apk update \
  && apk add --no-cache --virtual .build-deps git musl-dev \
  && git clone https://github.com/cloudflare/boringtun.git --branch $VERSION \
  && cd boringtun \
  && git checkout $VERSION \
  && cargo build --bin boringtun-cli --release \
  && strip target/release/boringtun-cli \
  && install target/release/boringtun-cli /usr/local/bin/ \
  && cd - \
  && rm -r boringtun \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine:3.16
LABEL maintainer="pexcn <i@pexcn.me>"

ARG WIREGUARD_VER=1.0.20210914-r0
RUN apk update \
  && apk add --no-cache tzdata \
      wireguard-tools=$WIREGUARD_VER \
      wireguard-tools-doc=$WIREGUARD_VER \
  && rm -rf /var/cache/apk/*

RUN install /usr/share/doc/wireguard-tools/contrib/reresolve-dns/reresolve-dns.sh /usr/local/bin/

COPY --from=builder /usr/local/bin/boringtun-cli /usr/local/bin/
COPY wireguard.sh /usr/local/bin/

ENV PEER_RESOLVE_INTERVAL=0

ENTRYPOINT ["wireguard.sh"]
