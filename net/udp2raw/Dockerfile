#
# Dockerfile for udp2raw
#

#
# Build stage
#
FROM alpine AS builder

ARG VERSION=8ceaf27edaff70505948fbfaf8b9b864e3a11ee8
RUN apk update \
  && apk add --no-cache --virtual .build-deps git make g++ linux-headers \
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
FROM alpine
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add --no-cache iptables ip6tables tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder /usr/local/bin/udp2raw /usr/local/bin/
COPY udp2raw.sh /usr/local/bin/

ENV USE_IPTABLES_NFT_BACKEND=0

ENTRYPOINT ["udp2raw.sh"]
CMD ["--help"]
