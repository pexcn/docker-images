#
# Dockerfile for shadowsocks-rust
#

#
# Build stage
#
FROM rust:alpine AS builder

RUN apk update \
  && apk add --no-cache --virtual .build-deps musl-dev git

ARG SS_VERSION=v1.10.4
RUN git clone https://github.com/shadowsocks/shadowsocks-rust.git --branch $SS_VERSION \
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
# Build stage (C)
#
FROM alpine AS builder-c

RUN apk update \
  && apk add --no-cache --virtual .build-deps \
      build-base autoconf automake libtool \
      git linux-headers libev-dev

ARG OBFS_VERSION=486bebd9208539058e57e23a12f23103016e09b4
RUN git clone https://github.com/shadowsocks/simple-obfs.git --recurse-submodules -j2 \
  && cd simple-obfs \
  && git checkout $OBFS_VERSION \
  && ./autogen.sh \
  && ./configure --prefix="/app" --disable-documentation --disable-assert \
  && make -j$(nproc) \
  && make install-strip \
  && cd .. \
  && rm -r simple-obfs

RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Build stage (Go)
#
FROM golang:alpine AS builder-go

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
  && apk add --no-cache libev

COPY --from=builder /app/ /app/
COPY --from=builder-c /app/bin/ /app/
COPY --from=builder-go /app/ /app/
COPY entrypoint.sh /app/

# set capabilities
RUN apk add --no-cache libcap \
  && rm -rf /var/cache/apk/*
RUN setcap cap_net_bind_service,cap_net_admin+ep /app/sslocal \
  && setcap cap_net_bind_service+ep /app/ssserver \
  && setcap cap_net_bind_service+ep /app/ssmanager \
  && setcap cap_net_bind_service+ep /app/obfs-local \
  && setcap cap_net_bind_service+ep /app/obfs-server \
  && setcap cap_net_bind_service+ep /app/v2ray-plugin \
  && setcap cap_net_bind_service+ep /app/xray-plugin

USER nobody
ENTRYPOINT ["/app/entrypoint.sh"]
