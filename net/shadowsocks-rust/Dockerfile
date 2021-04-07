#
# Dockerfile for shadowsocks-rust
#

#
# Build stage
#
FROM rust:alpine AS builder

RUN apk update \
  && apk add --no-cache --virtual .build-deps musl-dev git

ARG SS_RUST_VER=v1.10.3
RUN git clone https://github.com/shadowsocks/shadowsocks-rust.git --branch $SS_RUST_VER \
  && cd shadowsocks-rust \
  && RUSTFLAGS="-C link-arg=-s" cargo build --release --features "local-redir" \
  && mkdir /app \
  && cp /shadowsocks-rust/target/release/sslocal /app \
  && cp /shadowsocks-rust/target/release/ssserver /app \
  && cp /shadowsocks-rust/target/release/ssmanager /app \
  && cp /shadowsocks-rust/target/release/ssurl /app \
  && rm -r /shadowsocks-rust

RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

COPY --from=builder /app/ /app/
COPY entrypoint.sh /app/

# allow bind port less than 1024 & grant network admin capability
RUN apk update \
  && apk add --no-cache libcap \
  && rm -rf /var/cache/apk/*
RUN setcap cap_net_bind_service,cap_net_admin+ep /app/sslocal \
  && setcap cap_net_bind_service+ep /app/ssserver \
  && setcap cap_net_bind_service+ep /app/ssmanager

USER nobody
ENTRYPOINT ["/app/entrypoint.sh"]
