#
# Dockerfile for shadowsocks-libev
#

#
# Build stage [shadowsocks-libev]
#
FROM alpine:3.23 AS builder-ss

RUN apk update \
  && apk add --no-cache --virtual .build-deps \
      build-base linux-headers cmake git \
      pcre2-dev mbedtls-dev libsodium-dev c-ares-dev libev-dev \
      mbedtls-static libsodium-static pcre2-static \
      libmnl-dev libnftnl-dev libmnl-static \
      autoconf automake libtool

ARG SS_VERSION=5c47b80f4ed88975b131459e0a05072cc3fe4507
RUN git clone https://github.com/shadowsocks/shadowsocks-libev.git --recurse-submodules -j$(nproc) \
  && cd shadowsocks-libev \
  && git checkout $SS_VERSION \
  && mkdir build \
  && cmake -S . -B build \
      -DWITH_DOC_MAN=OFF \
      -DBUILD_TESTING=OFF \
      -DENABLE_NFTABLES=ON \
      -DCMAKE_BUILD_TYPE="Release" \
      -DCMAKE_EXE_LINKER_FLAGS="-static -no-pie -Wl,--build-id=none -s" \
      -DCMAKE_C_FLAGS="-O3 -pipe -Wno-error=sizeof-array-div" \
      -DCMAKE_C_STANDARD_LIBRARIES="-lnftnl -lmnl" \
      -DMBEDTLS_CRYPTO_LIBRARY=/usr/lib/libmbedcrypto.a \
      -DSODIUM_LIBRARY=/usr/lib/libsodium.a \
      -DCARES_LIBRARY=/usr/lib/libcares.a \
      -DMNL_LIB=/usr/lib/libmnl.a \
      -DNFTNL_LIB=/usr/lib/libnftnl.a \
  && cmake --build build --parallel $(nproc) --target ss-server ss-local ss-redir ss-tunnel ss-manager \
  && install -v -t /usr/local/bin \
      build/bin/ss-server \
      build/bin/ss-local \
      build/bin/ss-redir \
      build/bin/ss-tunnel \
      build/bin/ss-manager \
  && cd - \
  && rm -r shadowsocks-libev

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
# Build stage [shadowsocks-libev TFO compatible]
#
FROM alpine:3.23 AS builder-ss-tfo-cpt

RUN apk update \
  && apk add --no-cache --virtual .build-deps \
      build-base cmake git \
      pcre2-dev mbedtls-dev libsodium-dev c-ares-dev libev-dev \
      mbedtls-static libsodium-static pcre2-static \
      libmnl-dev libnftnl-dev libmnl-static \
      autoconf automake libtool
RUN echo "https://dl-cdn.alpinelinux.org/alpine/v3.8/main" >> /etc/apk/repositories \
  && apk update \
  && apk add --no-cache linux-headers=4.4.6-r2

ARG SS_VERSION=5c47b80f4ed88975b131459e0a05072cc3fe4507
RUN git clone https://github.com/shadowsocks/shadowsocks-libev.git --recurse-submodules -j$(nproc) \
  && cd shadowsocks-libev \
  && git checkout $SS_VERSION \
  && mkdir build \
  && cmake -S . -B build \
      -DWITH_DOC_MAN=OFF \
      -DBUILD_TESTING=OFF \
      -DENABLE_NFTABLES=ON \
      -DCMAKE_BUILD_TYPE="Release" \
      -DCMAKE_EXE_LINKER_FLAGS="-static -no-pie -Wl,--build-id=none -s" \
      -DCMAKE_C_FLAGS="-O3 -pipe -Wno-error=sizeof-array-div" \
      -DCMAKE_C_STANDARD_LIBRARIES="-lnftnl -lmnl" \
      -DMBEDTLS_CRYPTO_LIBRARY=/usr/lib/libmbedcrypto.a \
      -DSODIUM_LIBRARY=/usr/lib/libsodium.a \
      -DCARES_LIBRARY=/usr/lib/libcares.a \
      -DMNL_LIB=/usr/lib/libmnl.a \
      -DNFTNL_LIB=/usr/lib/libnftnl.a \
  && cmake --build build --parallel $(nproc) --target ss-server ss-local ss-redir ss-tunnel ss-manager \
  && install -v -t /usr/local/bin \
      build/bin/ss-server \
      build/bin/ss-local \
      build/bin/ss-redir \
      build/bin/ss-tunnel \
      build/bin/ss-manager \
  && cd - \
  && rm -r shadowsocks-libev

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

RUN apk del .build-deps linux-headers \
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
# Runtime stage
#
FROM alpine:3.23
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder-ss /usr/local/bin/ /usr/local/bin/
COPY --from=builder-ray /usr/local/bin/ /usr/local/bin/
COPY --from=builder-ss-tfo-cpt /usr/local/bin/ /srv/bin/
COPY shadowsocks-libev.sh /usr/local/bin/

ENTRYPOINT ["shadowsocks-libev.sh"]
CMD ["ss-server", "--help"]
