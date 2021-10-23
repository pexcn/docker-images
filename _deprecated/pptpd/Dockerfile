#
# Dockerfile for pptpd
#

FROM alpine:3.13
LABEL maintainer="pexcn <i@pexcn.me>"

# add depends
ARG PPTPD_VERSION=1.4.0-r2
ARG PPP_VERSION=2.4.8-r2
RUN apk update \
  && apk add --no-cache \
      pptpd=$PPTPD_VERSION \
      ppp=$PPP_VERSION \
      iptables \
  && rm -rf /var/cache/apk/*

# copy config
COPY pptpd.conf /etc/pptpd.conf
COPY pptpd-options /etc/ppp/pptpd-options
COPY entrypoint.sh /app/entrypoint.sh

ENV AUTH=
ENV FIX_MTU=

ENTRYPOINT ["/app/entrypoint.sh"]
