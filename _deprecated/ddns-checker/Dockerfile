#
# Dockerfile for ddns-checker
#

FROM alpine
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add tzdata curl \
  && rm -rf /var/cache/apk/*

ARG VER=679bd6c98c8503ef3e085de7c49aea63a3643cdb
RUN curl https://raw.githubusercontent.com/pexcn/ops.sh/${VER}/ddns-checker.sh -O --output-dir /usr/local/bin/ \
  && chmod +x /usr/local/bin/ddns-checker.sh

COPY restart-container.sh /usr/local/bin/

ENTRYPOINT ["ddns-checker.sh"]
