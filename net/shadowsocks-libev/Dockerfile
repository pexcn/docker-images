#
# Dockerfile for shadowsocks-libev
#

#
# Build stage (shadowsocks-libev)
#
FROM alpine AS builder-ss

RUN apk update \
  && apk add --no-cache --virtual .build-deps \
      build-base autoconf automake libtool pkgconfig linux-headers git \
      c-ares-dev mbedtls-dev pcre-dev libev-dev libsodium-dev \
      c-ares-static mbedtls-static libsodium-static

ARG SS_VERSION=6329526199674ddda8d8396a66072890b244972b
RUN git clone https://github.com/shadowsocks/shadowsocks-libev.git --recurse-submodules -j2 \
  && cd shadowsocks-libev \
  && git checkout $SS_VERSION \
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
  && rm -r shadowsocks-libev

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
# Build stage (v2ray-plugin & xray-plugin)
#
FROM golang:alpine AS builder-ray

RUN apk update \
  && apk add --no-cache --virtual .build-deps git

ARG V2RAY_VERSION=997ef6e19da10e689c1b9b724d36e9e869935523
RUN git clone https://github.com/shadowsocks/v2ray-plugin.git \
  && cd v2ray-plugin \
  && git checkout $V2RAY_VERSION \
  && env CGO_ENABLED=0 go build -v -trimpath -ldflags "-X main.VERSION=$(git describe --tags --abbrev=0) -s -w" -o v2ray-plugin \
  && mkdir -p /app \
  && mv v2ray-plugin /app \
  && cd .. \
  && rm -r v2ray-plugin

ARG XRAY_VERSION=v1.4.2
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

RUN apk update \
  && apk add --no-cache ca-certificates rng-tools

COPY --from=builder-ss /app/bin/ /app/
COPY --from=builder-ray /app/ /app/

ENV PATH=/app:$PATH
CMD ["ss-server", "--help"]
