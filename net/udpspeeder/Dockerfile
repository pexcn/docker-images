#
# Dockerfile for udpspeeder
#

#
# Build stage
#
FROM alpine:3.23 AS builder

ARG VERSION=67bf9fba43fa76e06c778fdb9d3cf50c64399fff
RUN apk update \
  && apk add --no-cache --virtual .build-deps git make g++ \
  && git clone https://github.com/docker-images-source/udpspeeder.git udpspeeder \
  && cd udpspeeder \
  && git checkout $VERSION \
  && make OPT="-no-pie -Wl,--build-id=none -s" \
  && install speederv2 /usr/local/bin/udpspeeder \
  && cd - \
  && rm -r udpspeeder \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine:3.23
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder /usr/local/bin/udpspeeder /usr/local/bin/

ENTRYPOINT ["udpspeeder"]
CMD ["--help"]
