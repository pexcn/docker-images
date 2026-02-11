#
# Dockerfile for pcap2socks
#

#
# Build stage
#
FROM rust:alpine AS builder

ARG VERSION=44665da6d8b98913218743065f47d9b6dd397fe0
RUN apk update \
  && apk add --no-cache --virtual .build-deps git musl-dev \
  && git clone https://github.com/docker-images-source/pcap2socks.git \
  && cd pcap2socks \
  && git checkout $VERSION \
  && cargo build --release \
  && strip target/release/pcap2socks \
  && install target/release/pcap2socks /usr/local/bin/pcap2socks \
  && cd - \
  && rm -r pcap2socks \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <pexcn97@gmail.com>"

COPY --from=builder /usr/local/bin/pcap2socks /usr/local/bin/

ENTRYPOINT ["pcap2socks"]
CMD ["--help"]
