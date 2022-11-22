#
# Dockerfile for tinyfecvpn
#

#
# Build stage
#
FROM alpine AS builder

ARG VERSION=cd4973c36fb75fb0d84241987febea41eee43611
RUN apk update \
  && apk add --no-cache --virtual .build-deps git make g++ linux-headers \
  && git clone https://github.com/wangyu-/tinyfecVPN.git tinyfecvpn --recursive \
  && cd tinyfecvpn \
  && git checkout $VERSION \
  && make OPT="-DNOLIMIT -s" \
  && install tinyvpn /usr/local/bin/tinyfecvpn \
  && cd - \
  && rm -r tinyfecvpn \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

RUN apk update \
  && apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder /usr/local/bin/tinyfecvpn /usr/local/bin/
COPY tinyfecvpn.sh /usr/local/bin/

ENTRYPOINT ["tinyfecvpn.sh"]
CMD ["--help"]
