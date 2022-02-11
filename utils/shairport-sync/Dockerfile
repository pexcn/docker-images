#
# Dockerfile for shairport-sync
#

FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

ARG VERSION=3.3.9-r0
RUN apk update \
  && apk add --no-cache dbus avahi \
  && apk add --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/testing shairport-sync=$VERSION

# run as an unprivileged user
RUN adduser -S -s /bin/ash airplay

COPY shairport-sync.sh /usr/local/bin/

ENV AUDIO_GID=29

ENTRYPOINT ["shairport-sync.sh"]
