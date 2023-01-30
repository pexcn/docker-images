#
# Dockerfile for cron
#

FROM alpine
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add tzdata curl \
  && rm -rf /var/cache/apk/*

COPY cron.sh /usr/local/bin/

ENV CRONTAB="* * * * * echo test"

ENTRYPOINT ["cron.sh"]
