#
# Dockerfile for smartmontools
#

FROM alpine:3.13
LABEL maintainer="pexcn <i@pexcn.me>"

# add depends
ARG SMARTMONTOOLS_VERSION=7.2-r1
ARG MSMTP_VERSION=1.8.14-r0
RUN apk update \
  && apk add --no-cache smartmontools=$SMARTMONTOOLS_VERSION msmtp=$MSMTP_VERSION \
  && apk add --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/testing mailutils

# set timezone
ENV TZ=Asia/Taipei
RUN apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

# Set soft link to unify my docker images
RUN mkdir /app && ln -s /usr/sbin/smartd /app/smartd

ENV SMARTD_CONFIG_PARAMS=

COPY entrypoint.sh /app/entrypoint.sh

USER root
ENTRYPOINT ["/app/entrypoint.sh"]
