#
# Dockerfile for shadowsocks-libev
#

#
# Build stage
#
FROM alpine AS builder

# add depends
RUN apk update \
  && apk add --no-cache --virtual .build-deps \
      build-base autoconf automake libtool linux-headers git \
      c-ares-dev mbedtls-dev pcre-dev libev-dev libsodium-dev

# build shadowsocks-libev
ARG SS_VERSION=6329526199674ddda8d8396a66072890b244972b
RUN git clone https://github.com/shadowsocks/shadowsocks-libev.git --recurse-submodules -j2 \
  && cd shadowsocks-libev \
  && git checkout $SS_VERSION \
  && ./autogen.sh \
  && ./configure --prefix="/app" --disable-documentation --disable-assert \
  && make -j$(nproc) \
  && make install-strip \
  && cd .. \
  && rm -r shadowsocks-libev \

# build simple-obfs
ARG OBFS_VERSION=486bebd9208539058e57e23a12f23103016e09b4
RUN git clone https://github.com/shadowsocks/simple-obfs.git --recurse-submodules -j2 \
  && cd simple-obfs \
  && git checkout $OBFS_VERSION \
  && ./autogen.sh \
  && ./configure --prefix="/app" --disable-documentation --disable-assert \
  && make -j$(nproc) \
  && make install-strip \
  && cd .. \
  && rm -r simple-obfs \

# clean up
RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

ENV SERVER_HOST=
ENV SERVER_PORT=
ENV PASSWORD=
ENV METHOD=chacha20-ietf-poly1305
ENV TIMEOUT=3600
ENV NOFILE=65535
ENV DNS_SERVERS=8.8.8.8,8.8.4.4
ENV MTU=1500
ENV PLUGIN=
ENV PLUGIN_OPTS=

ENV PATH=/app:$PATH

RUN apk update \
  && apk add --no-cache ca-certificates rng-tools \
      c-ares-dev mbedtls-dev pcre-dev libev-dev libsodium-dev

COPY --from=builder /app/bin/ss-* /app/
COPY --from=builder /app/bin/obfs-* /app/
COPY entrypoint.sh /app/entrypoint.sh

# allow bind port less than 1024
RUN apk add --no-cache libcap \
  && setcap cap_net_bind_service+ep /app/bin/ss-* /app/bin/obfs-* \
  && rm -rf /var/cache/apk/*

USER root
ENTRYPOINT ["/app/entrypoint.sh"]
