#
# Dockerfile for shadowsocks-libev
#

FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

ENV VERSION=13f472077d52c147057a198e552ea8cd6791631a
ENV GIT_URL=https://github.com/shadowsocks/shadowsocks-libev.git
ENV TZ=Asia/Taipei

ENV SERVER_HOST=
ENV SERVER_PORT=
ENV PASSWORD=
ENV METHOD chacha20-ietf-poly1305
ENV TIMEOUT 3600
ENV NOFILE 65535
ENV DNS_SERVERS 8.8.8.8,8.8.4.4
ENV MTU 1500

#
# Build stage
#

# add depends
RUN apk update \
  && apk add --no-cache c-ares-dev mbedtls-dev pcre-dev libev-dev libsodium-dev \
  && apk add --no-cache --virtual .build-deps build-base autoconf automake \
      libtool linux-headers git libcap

# build executable
RUN git clone $GIT_URL --recurse-submodules -j2 \
  && cd shadowsocks-libev && git checkout $VERSION \
  && ./autogen.sh \
  && ./configure --prefix="/app" --disable-documentation --disable-assert \
  && make -j$(nproc) && make install-strip \
  && cd .. && rm -r shadowsocks-libev \
  && ls /app/bin/ss-* | xargs -n1 setcap cap_net_bind_service+ep

# clean up
RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#

RUN apk add --no-cache ca-certificates rng-tools tzdata

COPY entrypoint.sh /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
