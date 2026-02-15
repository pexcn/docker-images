#
# Dockerfile for cpu-load
#

#
# Build stage
#
FROM alpine:3.23 AS builder

COPY cpu_load.c /src/
WORKDIR /src
RUN apk update \
  && apk add --no-cache --virtual .build-deps build-base linux-headers \
  && gcc -O3 -std=gnu11 -pthread -static -s -Wl,--build-id=none cpu_load.c -o cpu-load \
  && install cpu-load /usr/local/bin/ \
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

COPY --from=builder /usr/local/bin/cpu-load /usr/local/bin/
COPY cpu-load.sh /usr/local/bin/

ENV PERCENT_RANGE="40:60"
ENV TIME_RANGE="00:30-06:30"
ENV ACTIVE_SECONDS="7200"

ENTRYPOINT ["cpu-load.sh"]
