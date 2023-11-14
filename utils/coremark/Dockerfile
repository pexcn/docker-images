#
# Dockerfile for coremark
#

FROM alpine:3.18
LABEL maintainer="pexcn <pexcn97@gmail.com>"

ARG VERSION=d5fad6bd094899101a4e5fd53af7298160ced6ab
RUN apk update \
  && apk add --no-cache git gcc make musl-dev \
  && git clone https://github.com/eembc/coremark.git \
  && cd coremark \
  && git checkout $VERSION \
  && cd - \
  && rm -rf /var/cache/apk/*

COPY coremark.sh /usr/local/bin/

ENTRYPOINT ["coremark.sh"]
