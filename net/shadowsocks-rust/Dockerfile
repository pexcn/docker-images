#
# Dockerfile for shadowsocks-rust
#

#
# Build stage [shadowsocks-rust]
#
FROM rust:alpine AS builder-ss

RUN apk update \
  && apk add --no-cache --virtual .build-deps musl-dev git

ARG SS_VERSION=6490e34ec680138455e1e8441fdd3e1453c88d6d
RUN git clone https://github.com/shadowsocks/shadowsocks-rust.git \
  && cd shadowsocks-rust \
  && git checkout $SS_VERSION \
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

ARG V2RAY_VERSION=ddd7ab46b4aeee0ca8b272efed9d7da3e3a6e52c
RUN git clone https://github.com/shadowsocks/v2ray-plugin.git \
  && cd v2ray-plugin \
  && git checkout $V2RAY_VERSION \
  && env CGO_ENABLED=0 go build -v -trimpath -ldflags "-X main.VERSION=$(git describe --tags --abbrev=0) -s -w" -o v2ray-plugin \
  && mkdir -p /app \
  && mv v2ray-plugin /app \
  && cd .. \
  && rm -r v2ray-plugin

ARG XRAY_VERSION=88459fe77da1828ea56022523fe219a5d8e4ceb1
RUN git clone https://github.com/teddysun/xray-plugin.git \
  && cd xray-plugin \
  && git checkout $XRAY_VERSION \
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
