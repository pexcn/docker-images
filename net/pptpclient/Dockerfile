#
# Dockerfile for pptpclient
#

FROM alpine
LABEL maintainer="pexcn <pexcn97@gmail.com>"

ARG VERSION=1.10.0-r4
RUN apk update \
  && apk add --no-cache tzdata \
  && apk add --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/testing pptpclient=$VERSION \
  && rm -rf /var/cache/apk/*
