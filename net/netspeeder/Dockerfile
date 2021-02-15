#
# Dockerfile for netspeeder
#

#
# Build stage
#
FROM alpine AS builder

# add depends
RUN apk update \
  && apk add --no-cache --virtual .build-deps \
      build-base libnet-dev libpcap-dev

# build
ARG VERSION=b439a39c783f2bc11ec73ea7721c0d9373ff2815
RUN wget -O - -o /dev/null --no-check-certificate https://github.com/pexcn/netspeeder/archive/$VERSION.tar.gz | tar -zxf - \
  && cd netspeeder-$VERSION \
  && make \
  && make install DESTDIR="/app" \
  && cd .. \
  && rm -r netspeeder-$VERSION

# clean up
RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

# add depends
RUN apk update \
  && apk add --no-cache libnet libpcap \
  && rm -rf /var/cache/apk/*

COPY --from=builder /app/bin/netspeeder /app/netspeeder

USER root
ENTRYPOINT ["/app/netspeeder"]
