#
# Dockerfile for php-proxy
#

#
# Build stage
#
FROM golang:alpine AS builder

ARG VERSION=b6157aafda399df917ce004d0b7fa5073f9d2cb8
RUN apk update \
  && apk add --no-cache --virtual .build-deps git \
  && git clone https://github.com/koalabearguo/php-proxy.git \
  && cd php-proxy \
  && git checkout $VERSION \
  && go mod tidy \
  && go build -trimpath -ldflags "-s -w -buildid=" -o php-proxy *.go \
  && install php-proxy /usr/local/bin/ \
  && cd - \
  && rm -r php-proxy \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder /usr/local/bin/php-proxy /usr/local/bin/
COPY php-proxy.crt /etc/php-proxy/
COPY php-proxy.key /etc/php-proxy/

WORKDIR /tmp
USER nobody
ENTRYPOINT ["php-proxy", "-ca", "/etc/php-proxy/php-proxy.crt", "-key", "/etc/php-proxy/php-proxy.key"]
CMD ["--help"]
