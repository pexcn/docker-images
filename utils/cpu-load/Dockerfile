#
# Dockerfile for cpu-load
#

#
# Build stage
#
FROM alpine:3.23 AS builder

ARG VERSION=ee11464dedd92d6b7b81f5a305a37b21b8dc1ab2
RUN --mount=type=ssh \
  apk update \
  && apk add --no-cache --virtual .build-deps build-base git openssh-client \
  && mkdir -p -m 0700 /root/.ssh && ssh-keyscan github.com >> /root/.ssh/known_hosts \
  && git clone git@github.com:pexcn/cpu-load.git \
  && cd cpu-load \
  && git checkout $VERSION \
  && gcc -O3 -std=gnu11 -pthread -static -s -Wl,--build-id=none cpu_load.c -o cpu-load \
  && install cpu-load /usr/local/bin/ \
  && cd - \
  && rm -r cpu-load \
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

ENTRYPOINT ["cpu-load"]
