#
# Dockerfile for pcap2socks
#

#
# Build stage
#
FROM rust:alpine AS builder

COPY patches/*.patch /patches/
ARG VERSION=07dcd66fd8d9f51d24bac383e9f9c0b0d6a1ad83
RUN apk update \
  && apk add --no-cache --virtual .build-deps git musl-dev \
  && git clone https://github.com/zhxie/pcap2socks.git \
  && cd pcap2socks \
  && git checkout $VERSION \
  && for p in /patches/*.patch; do git apply -v "$p"; done \
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
