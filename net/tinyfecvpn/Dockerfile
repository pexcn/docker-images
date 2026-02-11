#
# Dockerfile for tinyfecvpn
#

#
# Build stage
#
FROM alpine:3.23 AS builder

ARG VERSION=18f93ec9c7cfd73fe2cd0f65c2f340c00a3e136a
RUN apk update \
  && apk add --no-cache --virtual .build-deps git make g++ linux-headers \
  && git clone https://github.com/pexcn/tinyfecvpn.git tinyfecvpn --recursive \
  && cd tinyfecvpn \
  && git checkout $VERSION \
  && make OPT="-DNOLIMIT -no-pie -Wl,--build-id=none -s" \
  && install tinyvpn /usr/local/bin/tinyfecvpn \
  && cd - \
  && rm -r tinyfecvpn \
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

COPY --from=builder /usr/local/bin/tinyfecvpn /usr/local/bin/
COPY tinyfecvpn.sh /usr/local/bin/

ENV USE_IPTABLES_NFT_BACKEND=0

ENTRYPOINT ["tinyfecvpn.sh"]
CMD ["--help"]
