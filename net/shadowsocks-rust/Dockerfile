#
# Dockerfile for shadowsocks-rust
#

#
# Build stage [shadowsocks-rust]
#
FROM rustlang/rust:nightly-alpine AS builder-ss

RUN apk update \
  && apk add --no-cache --virtual .build-deps musl-dev git

ARG SS_VERSION=v1.14.3
RUN git clone https://github.com/shadowsocks/shadowsocks-rust.git --branch $SS_VERSION \
  && cd shadowsocks-rust \
  && case "$(apk --print-arch)" in \
       aarch64) build_features="local-redir local-tun armv8 neon";; \
       *) build_features="local-redir local-tun";; \
     esac \
  && cargo build --release --features "$build_features" \
  && install target/release/ssservice target/release/ssserver target/release/sslocal target/release/ssmanager target/release/ssurl /usr/local/bin/ \
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
FROM golang:1.18-alpine AS builder-ray

RUN apk update \
  && apk add --no-cache --virtual .build-deps git

ARG V2RAY_VERSION=v5.0.7
RUN git clone https://github.com/teddysun/v2ray-plugin.git --branch $V2RAY_VERSION \
  && cd v2ray-plugin \
  && env CGO_ENABLED=0 go build -v -trimpath -ldflags "-X main.VERSION=$(git describe --tags --abbrev=0) -s -w -buildid=" -o v2ray-plugin \
  && install v2ray-plugin /usr/local/bin/ \
  && cd .. \
  && rm -r v2ray-plugin

ARG XRAY_VERSION=v1.5.8
RUN git clone https://github.com/teddysun/xray-plugin.git --branch $XRAY_VERSION \
  && cd xray-plugin \
  && env CGO_ENABLED=0 go build -v -trimpath -ldflags "-X main.VERSION=$(git describe --tags --abbrev=0) -s -w -buildid=" -o xray-plugin \
  && install xray-plugin /usr/local/bin/ \
  && cd .. \
  && rm -r xray-plugin

RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

COPY --from=builder-ss /usr/local/bin/ /usr/local/bin/
COPY --from=builder-obfs /usr/local/bin/ /usr/local/bin/
COPY --from=builder-ray /usr/local/bin/ /usr/local/bin/
COPY shadowsocks-rust.sh /usr/local/bin/

RUN cd /usr/local/bin/ \
  && ln -s ssservice service \
  && ln -s ssserver server \
  && ln -s sslocal local \
  && ln -s ssmanager manager \
  && ln -s ssurl url \
  && ln -s v2ray-plugin pv-plugin \
  && ln -s xray-plugin px-plugin \
  && ln -s obfs-server mix-server \
  && ln -s obfs-local mix-local

ENV CHILLING_EFFECT=0
ENTRYPOINT ["shadowsocks-rust.sh"]
CMD ["ssserver", "--version"]
