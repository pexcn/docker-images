#
# Dockerfile for ipt2socks
#

#
# Build stage
#
FROM alpine AS builder

# depends
RUN apk update \
  && apk add --no-cache --virtual .build-deps build-base linux-headers git

# build
ARG VERSION=c1413335f0b5f15241d7072204902778d122a578
RUN git clone https://github.com/zfl9/ipt2socks.git \
  && cd ipt2socks \
  && git checkout $VERSION \
  && make -j$(nproc) EVCFLAGS="-w -O3 -pipe" CFLAGS="-std=c99 -Wall -Wextra -O3 -pipe -pthread" \
  && make install DESTDIR="/app" \
  && make clean \
  && cd .. \
  && rm -r ipt2socks

# clean
RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

COPY --from=builder /app/ipt2socks /app/ipt2socks

# allow bind port less than 1024 & grant network admin capability
RUN apk update \
  && apk add --no-cache libcap \
  && rm -rf /var/cache/apk/*
RUN setcap cap_net_bind_service,cap_net_admin+ep /app/ipt2socks

USER nobody
ENTRYPOINT ["/app/ipt2socks"]
