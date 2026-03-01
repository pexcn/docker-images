#
# Dockerfile for shadowsocks-rust
#

#
# Build stage [shadowsocks-rust]
#
FROM rust:slim-trixie AS builder-ss

RUN apt-get update \
  && apt-get install --no-install-recommends -y curl xz-utils git clang \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ARG SS_VERSION=v1.23.5
SHELL ["/bin/bash", "-c"]
RUN case "$(dpkg --print-architecture)" in \
      amd64) \
        RUST_TARGET='x86_64-unknown-linux-musl' \
        && curl -L https://github.com/cross-tools/musl-cross/releases/download/20250929/${RUST_TARGET}.tar.xz | tar -xJf - -C /opt/ \
        ;; \
      arm64) \
        RUST_TARGET='aarch64-unknown-linux-musl' \
        && curl -L https://github.com/pexcn/docker-images/releases/download/rust-cross/aarch64_${RUST_TARGET}.tar.xz | tar -xJf - -C /opt/ \
        ;; \
    esac \
  && PATH="/opt/${RUST_TARGET}/bin:$PATH" \
  && export CC_"${RUST_TARGET//-/_}"=${RUST_TARGET}-gcc \
  && export CXX_"${RUST_TARGET//-/_}"=${RUST_TARGET}-g++ \
  && export AR_"${RUST_TARGET//-/_}"=${RUST_TARGET}-ar \
  && export RANLIB_"${RUST_TARGET//-/_}"=${RUST_TARGET}-ranlib \
  && export STRIP_"${RUST_TARGET//-/_}"=${RUST_TARGET}-strip \
  && export CARGO_TARGET_"$(echo $RUST_TARGET | tr '[:lower:]-' '[:upper:]_')"_LINKER=${RUST_TARGET}-gcc \
  && rustup target add $RUST_TARGET \
  && git clone https://github.com/shadowsocks/shadowsocks-rust.git --branch $SS_VERSION \
  && cd shadowsocks-rust \
  # fix rustfmt missing when compile librocksdb
  && rustup component add rustfmt \
  # fix librocksdb compile, ref: https://github.com/facebook/rocksdb/issues/13365#issuecomment-2833978676
  && export CXXFLAGS="$CXXFLAGS -include cstdint" \
  && cargo build --release --target $RUST_TARGET --features "full dns-over-h3 local-fake-dns aead-cipher-extra aead-cipher-2022-extra" \
  && install target/${RUST_TARGET}/release/{ssservice,ssserver,sslocal,ssmanager,ssurl} /usr/local/bin/ \
  && cd - \
  && rm -r shadowsocks-rust

#
# Build stage [simple-obfs]
#
FROM alpine AS builder-obfs

RUN apk update \
  && apk add --no-cache --virtual .build-deps \
      build-base autoconf automake libtool linux-headers git libev-dev

COPY patches/simple-obfs/*.patch /patches/
ARG OBFS_VERSION=486bebd9208539058e57e23a12f23103016e09b4
RUN git clone https://github.com/shadowsocks/simple-obfs.git --recurse-submodules -j$(nproc) \
  && cd simple-obfs \
  && git checkout $OBFS_VERSION \
  && for p in /patches/*.patch; do git apply -v "$p"; done \
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
  && cd - \
  && rm -r simple-obfs

RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Build stage [v2ray-plugin & xray-plugin]
#
FROM golang:1.26-alpine AS builder-ray

RUN apk update \
  && apk add --no-cache --virtual .build-deps git

ARG V2RAY_VERSION=v5.46.0
RUN git clone https://github.com/teddysun/v2ray-plugin.git --branch $V2RAY_VERSION \
  && cd v2ray-plugin \
  && env CGO_ENABLED=0 go build -v -trimpath -ldflags "-X main.VERSION=$(git describe --tags --abbrev=0) -s -w -buildid=" -o v2ray-plugin \
  && install v2ray-plugin /usr/local/bin/ \
  && cd - \
  && rm -r v2ray-plugin

ARG XRAY_VERSION=v1.8.24
RUN git clone https://github.com/teddysun/xray-plugin.git --branch $XRAY_VERSION \
  && cd xray-plugin \
  && env CGO_ENABLED=0 go build -v -trimpath -ldflags "-X main.VERSION=$(git describe --tags --abbrev=0) -s -w -buildid=" -o xray-plugin \
  && install xray-plugin /usr/local/bin/ \
  && cd - \
  && rm -r xray-plugin

RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Build stage [qtun]
#
FROM rust:alpine AS builder-qtun

ARG QTUN_VERSION=db2e18c3555bcae27148c6bac3594ff969ed5634
RUN apk update \
  && apk add --no-cache --virtual .build-deps git musl-dev \
  && git clone https://github.com/shadowsocks/qtun.git \
  && cd qtun \
  && git checkout $QTUN_VERSION \
  && cargo build --release \
  && strip target/release/qtun-server target/release/qtun-client \
  && install target/release/qtun-server target/release/qtun-client /usr/local/bin/ \
  && cd - \
  && rm -r qtun \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine:3.23
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder-ss /usr/local/bin/ /usr/local/bin/
COPY --from=builder-obfs /usr/local/bin/ /usr/local/bin/
COPY --from=builder-ray /usr/local/bin/ /usr/local/bin/
COPY --from=builder-qtun /usr/local/bin/ /usr/local/bin/
COPY shadowsocks-rust.sh /usr/local/bin/

RUN cd /usr/local/bin/ \
  && ln -s ssservice service \
  && ln -s ssserver server \
  && ln -s sslocal local \
  && ln -s ssmanager manager \
  && ln -s ssurl url \
  && ln -s obfs-server mix-server \
  && ln -s obfs-local mix-local \
  && ln -s v2ray-plugin pv-plugin \
  && ln -s xray-plugin px-plugin \
  && ln -s qtun-server qt-server \
  && ln -s qtun-client qt-client

ENV CHILLING_EFFECT=0

ENTRYPOINT ["shadowsocks-rust.sh"]
CMD ["ssserver", "--version"]
