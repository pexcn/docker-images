#
# Dockerfile for shadowsocks-libev
#

#
# Build stage
#
FROM alpine AS builder

RUN apk update \
  && apk add --no-cache --virtual .build-deps \
      build-base autoconf automake libtool linux-headers git \
      c-ares-dev mbedtls-dev pcre-dev libev-dev libsodium-dev

ARG SS_VERSION=6329526199674ddda8d8396a66072890b244972b
RUN git clone https://github.com/shadowsocks/shadowsocks-libev.git --recurse-submodules -j2 \
  && cd shadowsocks-libev \
  && git checkout $SS_VERSION \
  && ./autogen.sh \
  && ./configure --prefix="/app" --disable-documentation --disable-assert \
  && make -j$(nproc) \
  && make install-strip \
  && cd .. \
  && rm -r shadowsocks-libev

ARG OBFS_VER=486bebd9208539058e57e23a12f23103016e09b4
RUN git clone https://github.com/shadowsocks/simple-obfs.git --recurse-submodules -j2 \
  && cd simple-obfs \
  && git checkout $OBFS_VER \
  && ./autogen.sh \
  && ./configure --prefix="/app" --disable-documentation --disable-assert \
  && make -j$(nproc) \
  && make install-strip \
  && cd .. \
  && rm -r simple-obfs

RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

RUN apk update \
  && apk add --no-cache ca-certificates rng-tools \
      c-ares mbedtls pcre libev libsodium

COPY --from=builder /app/bin/ /app/
COPY entrypoint.sh /app/

# set capabilities
RUN apk add --no-cache libcap \
  && rm -rf /var/cache/apk/*
RUN ls /app/ss-* /app/obfs-* | xargs -n 1 setcap cap_net_bind_service+ep \
  && ls /app/ss-redir | xargs -n 1 setcap cap_net_bind_service,cap_net_admin+ep

USER nobody
ENTRYPOINT ["/app/entrypoint.sh"]
