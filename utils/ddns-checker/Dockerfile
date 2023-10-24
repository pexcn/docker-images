#
# Dockerfile for ddns-checker
#

FROM alpine
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add tzdata curl \
  && rm -rf /var/cache/apk/*

ARG VER=8be64ed9f0ec82588f73e669691a1c35904f891a
RUN curl https://raw.githubusercontent.com/pexcn/ops.sh/${VER}/ddns-checker.sh -O --output-dir /usr/local/bin/ \
  && chmod +x /usr/local/bin/ddns-checker.sh

COPY restart-container.sh /usr/local/bin/

ENTRYPOINT ["ddns-checker.sh"]
