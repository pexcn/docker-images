#
# Dockerfile for webdav
#

#
# Build stage
#
FROM golang:alpine AS builder

ARG VERSION=v4.1.1
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
LABEL maintainer="pexcn <i@pexcn.me>"

RUN apk update \
  && apk add tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder /usr/local/bin/webdav /usr/local/bin/
COPY webdav.sh /usr/local/bin/

VOLUME /data

#RUN chown -R nobody:nobody /srv
#USER nobody

ENTRYPOINT ["webdav.sh"]
