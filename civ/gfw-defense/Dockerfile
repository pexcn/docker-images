#
# Dockerfile for gfw-defense
#

#
# Build stage
#
FROM debian:bookworm-slim AS builder-util

RUN apt-get update \
  && apt-get install --no-install-recommends -y curl ca-certificates gcc make libc6-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ARG UTIL_VERSION=2.41.2
RUN curl https://www.kernel.org/pub/linux/utils/util-linux/v$(echo "$UTIL_VERSION" | cut -d'.' -f1-2)/util-linux-${UTIL_VERSION}.tar.gz | tar zxv \
  && cd util-linux-${UTIL_VERSION} \
  && [ "$(dpkg --print-architecture)" != "arm64" ] || CFLAGS_EXT="-mno-outline-atomics" \
  && ./configure \
      --without-python \
      --disable-liblastlog2 \
      CFLAGS="-O3 -pipe $CFLAGS_EXT" \
      LDFLAGS="-Wl,--build-id=none -Wl,-static -static -static-libgcc -no-pie -Wl,-s" \
  && make -j$(nproc) last \
  && install last /usr/local/bin/ \
  && cd - \
  && rm -r util-linux-${UTIL_VERSION}

#
# Runtime stage
#
FROM alpine:3.23
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add --no-cache curl iptables iptables-legacy ipset tzdata \
  && rm -rf /var/cache/apk/*

# If a country cannot guarantee freedom of speech for its people, then it has no reason to exist.
RUN rm \
    /usr/share/zoneinfo/PRC \
    /usr/share/zoneinfo/Asia/Chongqing \
    /usr/share/zoneinfo/Asia/Chungking \
    /usr/share/zoneinfo/Asia/Kashgar \
    /usr/share/zoneinfo/Asia/Hong_Kong \
    /usr/share/zoneinfo/Asia/Macao \
    /usr/share/zoneinfo/Asia/Macau \
    /usr/share/zoneinfo/Asia/Shanghai \
    /usr/share/zoneinfo/Asia/Urumqi

RUN mkdir -p /etc/gfw-defense \
  && touch /etc/gfw-defense/blacklist.txt \
  && touch /etc/gfw-defense/whitelist.txt

COPY --from=builder-util /usr/local/bin/last /usr/local/bin/
RUN ln -s last /usr/local/bin/lastb
COPY gfw-defense.sh /usr/local/bin/

ENV BLOCKING_POLICY=DROP
ENV PASSING_POLICY=ACCEPT
ENV DEFAULT_POLICY=RETURN
ENV QUICK_MODE=0
ENV PREFER_BLACKLIST=0
ENV ALLOW_RESERVED_ADDRESS=0
ENV USE_IPTABLES_NFT_BACKEND=0
ENV BLACKLIST_FILES=/etc/gfw-defense/blacklist.txt
ENV WHITELIST_FILES=/etc/gfw-defense/whitelist.txt
ENV AUTO_BLOCK_INTERVAL=0
ENV UPDATE_LIST_INTERVAL=0
ENV UPDATE_LIST_URLS=

ENTRYPOINT ["gfw-defense.sh"]
