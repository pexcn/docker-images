#
# Dockerfile for socks5-monitor
#

#
# Build stage
#
FROM golang:1.26-alpine AS builder
LABEL maintainer="pexcn <pexcn97@gmail.com>"

ARG VERSION=0efee38fdfb0473c30c7b9a9a8abbc1471f85991
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

ENV PATH=/usr/local/bin
ENTRYPOINT ["socks5-monitor"]
