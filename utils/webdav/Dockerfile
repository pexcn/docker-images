#
# Dockerfile for webdav
#

#
# Build stage
#
FROM golang:alpine AS builder

ARG VERSION=v4.2.0
RUN apk update \
  && apk add --no-cache --virtual .build-deps git gcc musl-dev \
  && git clone https://github.com/hacdias/webdav.git --branch $VERSION \
  && cd webdav \
  && CGO_ENABLED=0 go build -trimpath -ldflags="-w -s" -v \
  && cp webdav /usr/local/bin/ \
  && cd .. \
  && rm -r webdav \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder /usr/local/bin/webdav /usr/local/bin/
COPY webdav.sh /usr/local/bin/

ENV UID=1000
ENV GID=1000

VOLUME /data

ENTRYPOINT ["webdav.sh"]
