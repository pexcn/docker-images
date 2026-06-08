#
# Dockerfile for wireguard
#

#
# Build stage
#
FROM golang:1.26-alpine AS builder

ARG VERSION=0.0.20250522
RUN apk add --no-cache --virtual .build-deps git make \
  && git clone https://github.com/WireGuard/wireguard-go.git --branch $VERSION \
  && cd wireguard-go \
  && git checkout $VERSION \
  && sed -i 's/go build -v -o "$@"/env CGO_ENABLED=0 go build -v -trimpath -ldflags "-s -w -buildid=" -o "$@"/' Makefile \
  && make \
  && make install \
  && cd - \
  && rm -r wireguard-go \
  && apk del .build-deps

#
# Runtime stage
#
FROM alpine:3.23
LABEL maintainer="pexcn <pexcn97@gmail.com>"

ARG WIREGUARD_VER=1.0.20210914-r0
RUN apk add --no-cache tzdata iptables iptables-legacy \
      wireguard-tools wireguard-tools-doc

RUN install /usr/share/doc/wireguard-tools/contrib/reresolve-dns/reresolve-dns.sh /usr/local/bin/

COPY --from=builder /usr/bin/wireguard-go /usr/local/bin/
COPY wireguard.sh /usr/local/bin/

ENV PEER_RESOLVE_INTERVAL=0
ENV USE_IPTABLES_NFT_BACKEND=0

ENTRYPOINT ["wireguard.sh"]
