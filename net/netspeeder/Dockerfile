#
# Dockerfile for netspeeder
#

#
# Build stage
#
FROM alpine AS builder

RUN apk update \
  && apk add --no-cache --virtual .build-deps \
      build-base git libnet-dev libnet-static libpcap-dev

ARG VERSION=ca7a81387dfe3e7a0985e3efc8895ece46228e34
RUN git clone https://github.com/pexcn/netspeeder.git \
  && cd netspeeder \
  && git checkout $VERSION \
  && make static \
  && make install DESTDIR="/app" \
  && cd .. \
  && rm -r netspeeder

RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

COPY --from=builder /app/bin/netspeeder /app/netspeeder
COPY entrypoint.sh /app/entrypoint.sh

USER root
ENTRYPOINT ["/app/entrypoint.sh"]
