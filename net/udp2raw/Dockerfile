#
# Dockerfile for udp2raw
#

#
# Build stage
#
FROM alpine:3.23 AS builder

COPY patches/*.patch /patches/
ARG VERSION=4208db6e27c46f3ccec8b98722af7ec23bc62e73
RUN apk update \
  && apk add --no-cache --virtual .build-deps git make g++ linux-headers patch \
  && git clone https://github.com/wangyu-/udp2raw.git \
  && cd udp2raw \
  && git checkout $VERSION \
  && for p in /patches/*.patch; do git apply -v "$p"; done \
  && case $(apk --print-arch) in \
       x86_64) variant="amd64";; \
       aarch64) variant="arm64";; \
     esac \
  && make OPT="-no-pie -Wl,--build-id=none -s" ${variant} ${variant}_hw_aes \
  && install udp2raw_${variant} /usr/local/bin/udp2raw \
  && install udp2raw_${variant}_hw_aes /usr/local/bin/udp2raw-aes \
  && cd - \
  && rm -r udp2raw \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine:3.23
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add --no-cache iptables iptables-legacy tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder /usr/local/bin/udp2raw /usr/local/bin/
COPY --from=builder /usr/local/bin/udp2raw-aes /usr/local/bin/
COPY udp2raw.sh /usr/local/bin/

ENV USE_IPTABLES_NFT_BACKEND=0

ENTRYPOINT ["udp2raw.sh"]
CMD ["--help"]
