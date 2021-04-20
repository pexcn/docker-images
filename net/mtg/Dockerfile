#
# Dockerfile for mtg
#

#
# Build stage
#
FROM golang:alpine AS builder

# build
ARG VERSION=v2.0.0-rc1
RUN apk update \
  && apk add --no-cache --virtual .build-deps bash git make \
  && git clone https://github.com/9seconds/mtg.git --branch $VERSION \
  && cd mtg \
  && make -j$(nproc) static \
  && cp mtg /usr/local/bin/mtg \
  && cp example.config.toml /config.toml \
  && cd .. \
  && rm -r mtg \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

COPY --from=builder /usr/local/bin/mtg /usr/local/bin/mtg
COPY --from=builder /config.toml /config.toml

# allow bind port less than 1024
RUN apk update \
  && apk add --no-cache libcap \
  && rm -rf /var/cache/apk/*
RUN setcap cap_net_bind_service+ep /usr/local/bin/mtg

EXPOSE 3128
USER nobody
ENTRYPOINT ["mtg"]
CMD ["run", "/config.toml"]
