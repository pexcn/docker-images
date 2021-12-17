#
# Dockerfile for shadowsocks-rust
#

#
# Build stage [shadowsocks-rust]
#
FROM rust:alpine AS builder-ss

RUN apk update \
  && apk add --no-cache --virtual .build-deps musl-dev git

ARG SS_VERSION=v1.12.5
RUN git clone https://github.com/shadowsocks/shadowsocks-rust.git --branch $SS_VERSION \
  && cd shadowsocks-rust \
  && cargo build --release --features "local-redir local-tun" \
  && mkdir /app \
  && cp /shadowsocks-rust/target/release/sslocal /app \
  && cp /shadowsocks-rust/target/release/ssserver /app \
  && cp /shadowsocks-rust/target/release/ssmanager /app \
  && cp /shadowsocks-rust/target/release/ssurl /app \
  && cp /shadowsocks-rust/target/release/ssservice /app \
  # use strip instead set RUSTFLAGS
  && strip /app/ss* \
  && rm -r /shadowsocks-rust

RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Build stage [simple-obfs]
#
FROM alpine AS builder-obfs

RUN apk update \
  && apk add --no-cache --virtual .build-deps \
      build-base autoconf automake libtool pkgconfig linux-headers git \
      libev-dev

ARG OBFS_VERSION=486bebd9208539058e57e23a12f23103016e09b4
RUN git clone https://github.com/shadowsocks/simple-obfs.git --recurse-submodules -j2 \
  && cd simple-obfs \
  && git checkout $OBFS_VERSION \
  && ./autogen.sh \
  && ./configure \
      --prefix="/app" \
      --disable-documentation \
      --disable-assert \
      --enable-static \
      LIBS="-lpthread -lm" \
      CFLAGS="-O3 -pipe" \
      LDFLAGS="-Wl,--build-id=none -Wl,-static -static -static-libgcc -no-pie" \
  && make -j$(nproc) \
  && make install-strip \
  && cd .. \
  && rm -r simple-obfs

RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Build stage [v2ray-plugin & xray-plugin]
#
FROM golang:alpine AS builder-ray

RUN apk update \
  && apk add --no-cache --virtual .build-deps git

ARG V2RAY_VERSION=v4.44.0
RUN git clone https://github.com/teddysun/v2ray-plugin.git --branch $V2RAY_VERSION \
  && cd v2ray-plugin \
  && env CGO_ENABLED=0 go build -v -trimpath -ldflags "-X main.VERSION=$(git describe --tags --abbrev=0) -s -w" -o v2ray-plugin \
  && mkdir -p /app \
  && mv v2ray-plugin /app \
  && cd .. \
  && rm -r v2ray-plugin

ARG XRAY_VERSION=v1.5.0
RUN git clone https://github.com/teddysun/xray-plugin.git --branch $XRAY_VERSION \
  && cd xray-plugin \
  && env CGO_ENABLED=0 go build -v -trimpath -ldflags "-X main.VERSION=$(git describe --tags --abbrev=0) -s -w" -o xray-plugin \
  && mkdir -p /app \
  && mv xray-plugin /app \
  && cd .. \
  && rm -r xray-plugin

RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

COPY --from=builder-ss /app/ /app/
COPY --from=builder-obfs /app/bin/ /app/
COPY --from=builder-ray /app/ /app/

ENV PATH=/app:$PATH
CMD ["ssserver", "--version"]
