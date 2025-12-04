#
# Dockerfile for smartmontools
#

FROM alpine:3.22
LABEL maintainer="pexcn <pexcn97@gmail.com>"

ARG SMARTMONTOOLS_VERSION=7.5-r0
ARG MSMTP_VERSION=1.8.28-r0
ARG S_NAIL_VERSION=14.9.25-r0
RUN apk update \
  && apk add --no-cache \
      smartmontools=$SMARTMONTOOLS_VERSION \
      msmtp=$MSMTP_VERSION \
      s-nail=$S_NAIL_VERSION \
  && rm -rf /var/cache/apk/*

# make msmtp as sendmail alias
RUN ln -s /usr/bin/msmtp /usr/sbin/sendmail

COPY smartmontools.sh /usr/local/bin/
COPY smartd_warning_zh.sh /etc/

ENV SMARTD_CONFIG="DEVICESCAN"
ENV SMTP_CONFIG="mail@example.com#user:pass@smtp.example.com:587"

ENTRYPOINT ["smartmontools.sh"]
