#
# Dockerfile for ram-load
#

#
# Build stage
#
FROM alpine:3.23 AS builder

COPY ram_load.c /src/
WORKDIR /src
RUN apk update \
  && apk add --no-cache --virtual .build-deps build-base \
  && gcc -O3 -std=gnu11 -static -s -Wl,--build-id=none ram_load.c -o ram-load -lm \
  && install ram-load /usr/local/bin/ \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine:3.23
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder /usr/local/bin/ram-load /usr/local/bin/

ENTRYPOINT ["ram-load"]
