#
# Dockerfile for udp2raw
#

#
# Build stage
#
FROM alpine:3.19 AS builder

# patch for linux-headers to fix build
# waiting for edge to enter the next stable version...
ARG PATCH=https://github.com/torvalds/linux/commit/e2bca4870fdaf855651ee80b083d892599c5d982.patch
ARG VERSION=e42f0e573221c5e0146c02fd5d71f32aa93c7221
RUN apk update \
  && apk add --no-cache --virtual .build-deps git make g++ linux-headers \
  && apk add --no-cache curl patch \
  && curl $PATCH | patch /usr/include/linux/if_packet.h || true \
  && git clone https://github.com/wangyu-/udp2raw.git \
  && cd udp2raw \
  && git checkout $VERSION \
  && make OPT="-s -pipe -Wl,--build-id=none" \
  && install udp2raw /usr/local/bin/udp2raw \
  && cd - \
  && rm -r udp2raw \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
# https://www.alpinelinux.org/posts/Alpine-3.19.0-released.html
# make the version fixed at 3.18, version 3.19 maybe requires code changes.
FROM alpine:3.18
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add --no-cache iptables ip6tables tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder /usr/local/bin/udp2raw /usr/local/bin/
COPY udp2raw.sh /usr/local/bin/

ENV USE_IPTABLES_NFT_BACKEND=0

ENTRYPOINT ["udp2raw.sh"]
CMD ["--help"]
