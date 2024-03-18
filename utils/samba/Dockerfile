#
# Dockerfile for samba
#

FROM alpine:3.16
LABEL maintainer="pexcn <pexcn97@gmail.com>"

ARG SAMBA_VER=4.15.13-r0
RUN apk update \
  && apk add --no-cache samba=$SAMBA_VER \
  && rm -rf /var/cache/apk/*

COPY smb.conf /etc/samba/
COPY users /etc/samba/
COPY samba.sh /usr/local/bin/

EXPOSE 445/tcp 445/udp
ENTRYPOINT ["samba.sh"]
