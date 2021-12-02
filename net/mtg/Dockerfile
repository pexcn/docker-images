#
# Dockerfile for mtg
#

#
# Build stage
#
FROM golang:1.17-alpine AS builder

ARG VERSION=v2.1.3
RUN apk update \
  && apk add --no-cache --virtual .build-deps bash git make \
  && git clone https://github.com/9seconds/mtg.git --branch $VERSION \
  && cd mtg \
  && make -j$(nproc) static \
  && cp mtg /usr/local/bin/mtg \
  && cd .. \
  && rm -r mtg \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

COPY --from=builder /usr/local/bin/mtg /usr/local/bin/
COPY entrypoint.sh /usr/local/bin/

# allow bind port less than 1024
RUN apk update \
  && apk add --no-cache libcap \
  && rm -rf /var/cache/apk/*
RUN setcap cap_net_bind_service+ep /usr/local/bin/mtg

USER nobody

EXPOSE 3128
ENTRYPOINT ["entrypoint.sh"]
CMD ["--help"]
