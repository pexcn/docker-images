#
# Dockerfile for tinyfecvpn
#

#
# Build stage
#
FROM alpine:3.20 AS builder

ARG VERSION=057b71f28d7c41ee220804cead976ec60c7fd5c8
RUN apk update \
  && apk add --no-cache --virtual .build-deps git make g++ linux-headers \
  && git clone https://github.com/wangyu-/tinyfecVPN.git tinyfecvpn --recursive \
  && cd tinyfecvpn \
  && git checkout $VERSION \
  && make OPT="-s" \
  && install tinyvpn /usr/local/bin/tinyfecvpn \
  && cd - \
  && rm -r tinyfecvpn \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine:3.20
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add --no-cache iptables iptables-legacy tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder /usr/local/bin/tinyfecvpn /usr/local/bin/
COPY tinyfecvpn.sh /usr/local/bin/

ENV USE_IPTABLES_NFT_BACKEND=0

ENTRYPOINT ["tinyfecvpn.sh"]
CMD ["--help"]
