#
# Dockerfile for strongswan
#

FROM alpine:3.13
LABEL maintainer="pexcn <i@pexcn.me>"

ARG STRONGSWAN_VER=5.9.1-r0
ARG XL2TPD_VER=1.3.16-r0
RUN apk update \
  && apk add --no-cache \
      strongswan=$STRONGSWAN_VER \
      xl2tpd=$XL2TPD_VER
