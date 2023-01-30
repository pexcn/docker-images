#
# Dockerfile for kcptun-libev
#

#
# Build stage
#
FROM alpine AS builder

ARG VERSION=v2.1.1
RUN apk update \
  && apk add --no-cache --virtual .build-deps git cmake make gcc linux-headers musl-dev libev-dev libsodium-dev libsodium-static \
  && git clone https://github.com/hexian000/kcptun-libev.git --branch $VERSION \
  && cd kcptun-libev \
  && mkdir build \
  && cmake \
       -G "Unix Makefiles" \
       -DCMAKE_BUILD_TYPE="Release" \
       -DCMAKE_EXE_LINKER_FLAGS="-static" \
       -DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
       -DLINK_STATIC_LIBS=TRUE \
       -S . \
       -B build \
  && cmake --build build --parallel \
  && install build/src/kcptun-libev /usr/local/bin/ \
  && install -d /etc/kcptun-libev/ \
  && install -m 0644 server.json client.json /etc/kcptun-libev/ \
  && cd - \
  && rm -r kcptun-libev \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine:3.16
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder /usr/local/bin/kcptun-libev /usr/local/bin/
COPY --from=builder /etc/kcptun-libev/ /etc/kcptun-libev/

ENTRYPOINT ["kcptun-libev"]
CMD ["-c", "/etc/kcptun-libev/server.json"]
