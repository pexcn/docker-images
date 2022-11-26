#
# Dockerfile for motd
#

FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

RUN apk update \
  && apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

COPY motd.sh /usr/local/bin/

#ENTRYPOINT ["motd.sh"]
