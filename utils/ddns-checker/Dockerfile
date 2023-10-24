#
# Dockerfile for ddns-checker
#

FROM alpine
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add tzdata curl \
  && rm -rf /var/cache/apk/*

ARG VER=ca13abfa0669f2ca427ae0f25e1b37b64dc7a0b7
RUN curl https://raw.githubusercontent.com/pexcn/ops.sh/${VER}/ddns-checker.sh -O --output-dir /usr/local/bin/ \
  && chmod +x /usr/local/bin/ddns-checker.sh

COPY restart-container.sh /usr/local/bin/

ENTRYPOINT ["ddns-checker.sh"]
