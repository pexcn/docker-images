#
# Dockerfile for udp2raw
#

#
# Build stage
#
FROM alpine:3.23 AS builder

ARG VERSION=4968786892be6013f84a83ae8030fe6ca94a92c0
RUN apk update \
  && apk add --no-cache --virtual .build-deps git make g++ linux-headers patch \
  && git clone https://github.com/docker-images-source/udp2raw.git \
  && cd udp2raw \
  && git checkout $VERSION \
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
ENV USE_AES_VARIANT=1

ENTRYPOINT ["udp2raw.sh"]
CMD ["--help"]
