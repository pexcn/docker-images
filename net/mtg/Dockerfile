#
# Dockerfile for mtg
#

#
# Build stage
#
FROM golang:alpine AS builder

ENV VERSION=v1.0.7
ENV GIT_URL=https://github.com/9seconds/mtg.git

RUN apk update \
  && apk add --no-cache --virtual .build-deps bash ca-certificates curl git make \
  && git clone $GIT_URL --branch $VERSION /tmp/mtg \
  && cd /tmp/mtg \
  && make -j$(nproc) static \
  && mv /tmp/mtg/mtg /mtg \
  && make clean \
  && cd / \
  && rm -r /tmp/mtg \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

ENV BIND_ADDRESS 0.0.0.0:995
ENV ARGS=
ENV SECRET_KEY ee3471158e7a53644c047d6b6b8743f8ba62696e672e636f6d

# set timezone
ENV TZ=Asia/Taipei
RUN apk update \
  && apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder /mtg /app/mtg

USER nobody
ENTRYPOINT /app/mtg run -b $BIND_ADDRESS $ARGS $SECRET_KEY
