#
# Dockerfile for frp
#

#
# Build stage
#
FROM golang:1.17-alpine AS builder

ARG VERSION=v0.38.0
RUN apk update \
  && apk add --no-cache --virtual .build-deps git make \
  && git clone https://github.com/fatedier/frp.git --branch $VERSION \
  && cd frp \
  && make -j$(nproc) \
  && cp bin/frps bin/frpc /usr/local/bin/ \
  && cd .. \
  && rm -r frp \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

COPY --from=builder /usr/local/bin/frps /usr/local/bin/
COPY --from=builder /usr/local/bin/frpc /usr/local/bin/

# allow bind port less than 1024
RUN apk update \
  && apk add --no-cache libcap \
  && rm -rf /var/cache/apk/*
RUN setcap cap_net_bind_service+ep /usr/local/bin/frps \
  && setcap cap_net_bind_service+ep /usr/local/bin/frpc

USER nobody

EXPOSE 7000
CMD ["frps", "--version"]
