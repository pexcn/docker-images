#
# Dockerfile for socks5-monitor
#

#
# Build stage
#
FROM golang:1.26-alpine AS builder
LABEL maintainer="pexcn <pexcn97@gmail.com>"

ARG VERSION=8c2734d46d637696e9bb90f7c1f6468da6b37577
RUN --mount=type=ssh \
  apk add --no-cache --virtual .build-deps openssh-client git make \
  && mkdir -p -m 0700 /root/.ssh && ssh-keyscan github.com >> /root/.ssh/known_hosts \
  && git clone git@github.com:pexcn/socks5-monitor.git \
  && cd socks5-monitor \
  && git checkout $VERSION \
  && make \
  && make install \
  && cd - \
  && rm -r socks5-monitor \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM pexcn/docker-images:scratch
LABEL maintainer="pexcn <pexcn97@gmail.com>"

COPY --from=builder /usr/local/bin/socks5-monitor /usr/local/bin/

ENTRYPOINT ["socks5-monitor"]
