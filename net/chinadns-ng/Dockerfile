#
# Dockerfile for chinadns-ng
#

#
# Build stage
#
FROM alpine AS builder

# depends
RUN apk update \
  && apk add --no-cache --virtual .build-deps build-base linux-headers git

# build
ARG VERSION=14cc6348d67b09cae37d9bce554c89c2c0e0b265
RUN git clone https://github.com/zfl9/chinadns-ng.git \
  && cd chinadns-ng \
  && git checkout $VERSION \
  && make -j$(nproc) CFLAGS="-std=c99 -Wall -Wextra -O3 -pipe" \
  && make install DESTDIR="/app" \
  && make clean \
  && cd .. \
  && rm -r chinadns-ng

# clean
RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

COPY --from=builder /app/chinadns-ng /app/chinadns-ng

# allow bind port less than 1024
RUN apk update \
  && apk add --no-cache libcap \
  && rm -rf /var/cache/apk/*
RUN setcap cap_net_bind_service+ep /app/chinadns-ng

EXPOSE 65353/udp
USER nobody
ENTRYPOINT ["/app/chinadns-ng"]
