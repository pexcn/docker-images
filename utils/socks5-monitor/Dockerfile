#
# Dockerfile for socks5-monitor
#

#
# Build stage
#
FROM golang:1.26-alpine AS builder
LABEL maintainer="pexcn <pexcn97@gmail.com>"

ARG VERSION=48dcd9b7289946cc29f2018c2aa9dd41c96c114a
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

RUN apk add --no-cache tzdata ca-certificates

#
# Runtime stage
#
FROM scratch
LABEL maintainer="pexcn <pexcn97@gmail.com>"

COPY --from=builder /usr/local/bin/socks5-monitor /usr/local/bin/
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

ENV PATH=/usr/local/bin
ENTRYPOINT ["socks5-monitor"]
