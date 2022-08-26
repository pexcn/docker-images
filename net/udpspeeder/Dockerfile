#
# Dockerfile for udpspeeder
#

#
# Build stage
#
FROM alpine AS builder

ARG VERSION=fd72361deae7eebbaa814c3869babfd5539b1162
RUN apk update \
  && apk add --no-cache --virtual .build-deps git make g++ \
  && git clone https://github.com/wangyu-/UDPspeeder.git \
  && cd UDPspeeder \
  && git checkout $VERSION \
  && make OPT="-s -pipe -Wl,--build-id=none" \
  && install speederv2 /usr/local/bin/udpspeeder \
  && cd .. \
  && rm -r UDPspeeder \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine:3.16
LABEL maintainer="pexcn <i@pexcn.me>"

COPY --from=builder /usr/local/bin/udpspeeder /usr/local/bin/

ENTRYPOINT ["udpspeeder"]
CMD ["--help"]
