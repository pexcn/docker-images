#
# Dockerfile for samba
#

FROM alpine:3.15
LABEL maintainer="pexcn <i@pexcn.me>"

ARG SAMBA_VER=4.15.2-r0
RUN apk update \
  && apk add --no-cache samba=$SAMBA_VER \
  && rm -rf /var/cache/apk/*

ENTRYPOINT ["smbd", "--foreground", "--no-process-group"]
