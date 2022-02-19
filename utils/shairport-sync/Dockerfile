#
# Dockerfile for shairport-sync
#

#
# Build stage
#
FROM alpine AS builder

ARG ALSA_EXPLORE_VER=1d0614e19ec14eddc005aed31ead723bafcbe8d5
RUN apk update \
  && apk add --no-cache --virtual .build-deps git autoconf automake make gcc musl-dev pkgconf alsa-lib-dev \
  && git clone https://github.com/mikebrady/sps-alsa-explore.git \
  && cd sps-alsa-explore \
  && git checkout $ALSA_EXPLORE_VER \
  && autoreconf -fi \
  && ./configure \
  && make \
  && make install-strip \
  && make clean \
  && cd .. \
  && rm -r sps-alsa-explore \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

ARG VERSION=3.3.9-r0
RUN apk update \
  && apk add --no-cache dbus avahi alsa-utils alsa-lib \
  && apk add --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/testing shairport-sync=$VERSION

COPY --from=builder /usr/local/bin/sps-alsa-explore /usr/local/bin/
COPY shairport-sync.sh /usr/local/bin/

ENV AUDIO_GID=29
ENV CARD_NUM=0

ENTRYPOINT ["shairport-sync.sh"]
