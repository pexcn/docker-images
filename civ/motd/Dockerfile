#
# Dockerfile for motd
#

FROM alpine
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add --no-cache bash tzdata \
  && rm -rf /var/cache/apk/*

COPY messages /srv/messages/
COPY motd.sh /usr/local/bin/

ENV MESSAGE_HEADER=

ENTRYPOINT ["motd.sh"]
