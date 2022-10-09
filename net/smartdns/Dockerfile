#
# Dockerfile for smartdns
#

#
# Build stage
#
FROM alpine AS builder

ARG VERSION=Release38
RUN apk update \
  && apk add --no-cache --virtual .build-deps git make pkgconfig gcc musl-dev linux-headers openssl-dev openssl-libs-static \
  && git clone https://github.com/pymumu/smartdns.git --branch $VERSION \
  && cd smartdns \
  && sed -i '/SYSTEMDSYSTEMUNITDIR/d' Makefile \
  && make STATIC=yes LDFLAGS+=-s \
  && make install \
  && cd - \
  && rm -r smartdns \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine:3.16
LABEL maintainer="pexcn <i@pexcn.me>"

RUN apk update \
  && apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder /usr/sbin/smartdns /usr/local/bin/
COPY --from=builder /etc/smartdns/ /etc/smartdns/

ENTRYPOINT ["smartdns", "-f", "-x"]
CMD ["-c", "/etc/smartdns/smartdns.conf"]
