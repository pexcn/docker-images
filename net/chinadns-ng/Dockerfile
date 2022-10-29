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
ARG VERSION=e7c4ebd64af2690a153fb0e16a5f543d185545d6
RUN git clone https://github.com/zfl9/chinadns-ng.git \
  && cd chinadns-ng \
  && git checkout $VERSION \
  && make -j$(nproc) CFLAGS="-std=c99 -Wall -Wextra -O3 -pipe" \
  && make install \
  && make clean \
  && cd - \
  && rm -r chinadns-ng

# clean
RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

RUN apk update \
  && apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder /usr/local/bin/chinadns-ng /usr/local/bin/

# allow bind port less than 1024
RUN apk update \
  && apk add --no-cache libcap \
  && rm -rf /var/cache/apk/*
RUN setcap cap_net_bind_service+ep /usr/local/bin/chinadns-ng

USER nobody
ENTRYPOINT ["chinadns-ng"]
