#
# Dockerfile for smartmontools
#

FROM alpine:3.13
LABEL maintainer="pexcn <i@pexcn.me>"

# add depends
ARG SMARTMONTOOLS_VERSION=7.2-r1
ARG MSMTP_VERSION=1.8.14-r0
ARG S_NAIL_VERSION=14.9.20-r0
RUN apk update \
  && apk add --no-cache \
      smartmontools=$SMARTMONTOOLS_VERSION \
      msmtp=$MSMTP_VERSION \
      s-nail=$S_NAIL_VERSION

# set timezone
ENV TZ=Asia/Taipei
RUN apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

# make msmtp as sendmail alias
RUN ln -sf /usr/bin/msmtp /usr/sbin/sendmail

# set soft link to unify my docker images
RUN mkdir /app && ln -s /usr/sbin/smartd /app/smartd

ENV SMARTD_PARAMS=
ENV SMTP_CONFIG="who@free.hk#user:freehk@smtp.free.hk:587"

COPY entrypoint.sh /app/entrypoint.sh

USER root
ENTRYPOINT ["/app/entrypoint.sh"]
