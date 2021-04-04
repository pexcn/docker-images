#
# Dockerfile for tor
#

#
# Build stage
#
FROM alpine AS builder

# depends
RUN apk update \
  && apk add --no-cache --virtual .build-deps build-base \
      linux-headers libevent-dev openssl-dev zlib-dev xz-dev zstd-dev git

# build
ARG VERSION=0.4.5.7
RUN wget -O - -o /dev/null --no-check-certificate https://dist.torproject.org/tor-$VERSION.tar.gz | tar -zxf - \
  && cd tor-$VERSION \
  && ./configure --prefix=/app --enable-lzma --enable-zstd \
      --disable-unittests --disable-manpage --disable-html-manual --disable-asciidoc \
  && make -j$(nproc) \
  && make install-strip \
  && make clean \
  && cd .. \
  && rm -r tor-$VERSION

# clean
RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

RUN apk update \
  && apk add --no-cache libevent xz-libs zstd-libs

COPY --from=builder /app/ /app/
COPY torrc /app/etc/tor/

# allow bind port less than 1024
RUN apk add --no-cache libcap \
  && rm -rf /var/cache/apk/*
RUN setcap cap_net_bind_service+ep /app/bin/tor

# run as an unprivileged user
RUN addgroup -S tor && adduser -S tor -G tor
USER tor

ENTRYPOINT /app/bin/tor -f /app/etc/tor/torrc
