#
# Dockerfile for shadowsocks-libev
#

#
# Build stage [shadowsocks-libev]
#
FROM alpine AS builder-ss

RUN apk update \
  && apk add --no-cache --virtual .build-deps \
      build-base autoconf automake libtool pkgconfig linux-headers git \
      c-ares-dev mbedtls-dev pcre-dev libev-dev libsodium-dev \
      c-ares-static mbedtls-static libsodium-static

ARG SS_VERSION=46382c23fac8fbabb62130ef49d3f0bf4c807b43
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
# Build stage [shadowsocks-libev TFO compatible]
#
FROM alpine AS builder-ss-tfo-cpt

RUN apk update \
  && apk add --no-cache --virtual .build-deps \
      build-base autoconf automake libtool pkgconfig git \
      c-ares-dev mbedtls-dev pcre-dev libev-dev libsodium-dev \
      c-ares-static mbedtls-static libsodium-static
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.8/main" >> /etc/apk/repositories \
  && apk update \
  && apk add --no-cache linux-headers=4.4.6-r2

ARG SS_VERSION=46382c23fac8fbabb62130ef49d3f0bf4c807b43
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

RUN apk del .build-deps linux-headers \
  && rm -rf /var/cache/apk/*

#
# Build stage [v2ray-plugin & xray-plugin]
#
FROM golang:alpine AS builder-ray

RUN apk update \
  && apk add --no-cache --virtual .build-deps git

ARG V2RAY_VERSION=v5.0.2
RUN git clone https://github.com/teddysun/v2ray-plugin.git --branch $V2RAY_VERSION \
  && cd v2ray-plugin \
  && env CGO_ENABLED=0 go build -v -trimpath -ldflags "-X main.VERSION=$(git describe --tags --abbrev=0) -s -w" -o v2ray-plugin \
  && mkdir -p /app \
  && mv v2ray-plugin /app \
  && cd .. \
  && rm -r v2ray-plugin

ARG XRAY_VERSION=v1.5.4
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
  && apk add --no-cache ca-certificates \
  && rm -rf /var/cache/apk/*

COPY --from=builder-ss /app/bin/ /app/
COPY --from=builder-ray /app/ /app/
COPY --from=builder-ss-tfo-cpt /app/bin/ /app-compat/
COPY entrypoint.sh /app/

ENV PATH=/app:$PATH
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["ss-server", "--help"]
