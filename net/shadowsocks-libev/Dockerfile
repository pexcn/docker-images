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
      build-base autoconf automake libtool linux-headers git libcap \
      c-ares-dev mbedtls-dev pcre-dev libev-dev libsodium-dev

# build shadowsocks-libev
ENV SS_VERSION=13f472077d52c147057a198e552ea8cd6791631a
RUN git clone https://github.com/shadowsocks/shadowsocks-libev.git --recurse-submodules -j2 \
  && cd shadowsocks-libev \
  && git checkout $SS_VERSION \
  && ./autogen.sh \
  && ./configure --prefix="/app" --disable-documentation --disable-assert \
  && make -j$(nproc) \
  && make install-strip \
  && cd .. \
  && rm -r shadowsocks-libev \
  && ls /app/bin/ss-* | xargs -n1 setcap cap_net_bind_service+ep

# build simple-obfs
ENV OBFS_VERSION=486bebd9208539058e57e23a12f23103016e09b4
RUN git clone https://github.com/shadowsocks/simple-obfs.git --recurse-submodules -j2 \
  && cd simple-obfs \
  && git checkout $OBFS_VERSION \
  && ./autogen.sh \
  && ./configure --prefix="/app" --disable-documentation --disable-assert \
  && make -j$(nproc) \
  && make install-strip \
  && cd .. \
  && rm -r simple-obfs \
  && ls /app/bin/obfs-* | xargs -n1 setcap cap_net_bind_service+ep

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

ENV TZ=Asia/Taipei
ENV PATH=/app:$PATH

RUN apk update \
  && apk add --no-cache ca-certificates rng-tools tzdata \
      c-ares-dev mbedtls-dev pcre-dev libev-dev libsodium-dev \
  && rm -rf /var/cache/apk/*

COPY --from=builder /app/bin/ss-* /app/
COPY --from=builder /app/bin/obfs-* /app/
COPY entrypoint.sh /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
