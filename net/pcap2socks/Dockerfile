#
# Dockerfile for pcap2socks
#

#
# Build stage
#
FROM rust:alpine AS builder

ARG VERSION=ed015a40266feaa143ab531d57f923b076f88cbd
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
FROM pexcn/docker-images:alpine
LABEL maintainer="pexcn <pexcn97@gmail.com>"

COPY --from=builder /usr/local/bin/pcap2socks /usr/local/bin/

ENTRYPOINT ["pcap2socks"]
CMD ["--help"]
