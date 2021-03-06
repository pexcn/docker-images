#
# Dockerfile for hev-socks5-server
#

#
# Build stage
#
FROM alpine AS builder

# add depends
RUN apk update \
  && apk add --no-cache --virtual .build-deps build-base git

# build
ARG VERSION=1.9.9
RUN git clone https://github.com/heiher/hev-socks5-server.git --branch $VERSION --recurse-submodules -j2 \
  && cd hev-socks5-server \
  && make -j$(nproc) \
  && make install INSTDIR="/app" \
  && cd .. \
  && rm -r hev-socks5-server

# clean up
RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

# copy files
COPY --from=builder /app/ /app/
RUN chown nobody:nobody /app/etc
COPY hev-socks5-server.yml /app/etc/hev-socks5-server.yml
COPY entrypoint.sh /app/entrypoint.sh

# allow bind port less than 1024
RUN apk update \
  && apk add --no-cache libcap \
  && rm -rf /var/cache/apk/*
RUN setcap cap_net_bind_service+ep /app/bin/hev-socks5-server

EXPOSE 1080
USER nobody
ENTRYPOINT ["/app/entrypoint.sh"]
