#
# Dockerfile for mtg
#

#
# Build stage
#
FROM golang:1.15-alpine AS builder

ENV VERSION=v1.0.7
ENV GIT_URL=https://github.com/9seconds/mtg.git

# add depends
RUN apk add --no-cache --virtual .build-deps bash ca-certificates curl git make

# build executable
RUN git clone $GIT_URL --branch $VERSION && cd mtg \
  && make -j$(nproc) static \
  && mv ./mtg /mtg && make clean \
  && cd .. && rm -r mtg

# clean up
RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

ENV BIND_ADDRESS 0.0.0.0:995
ENV ARGS=
ENV SECRET_KEY ee3471158e7a53644c047d6b6b8743f8ba62696e672e636f6d

ENV TZ=Asia/Taipei

RUN apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder /mtg /app/mtg

USER nobody
ENTRYPOINT /app/mtg run -b $BIND_ADDRESS $ARGS $SECRET_KEY
