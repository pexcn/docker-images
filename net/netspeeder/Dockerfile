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

ARG VERSION=a3009b5945aede38a8afe188f71a6956033b1432
RUN git clone https://github.com/pexcn/netspeeder.git \
  && cd netspeeder \
  && git checkout $VERSION \
  && make static \
  && make install \
  && cd - \
  && rm -r netspeeder

RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <pexcn97@gmail.com>"

COPY --from=builder /usr/local/bin/netspeeder /usr/local/bin/
COPY netspeeder.sh /usr/local/bin/

USER root
ENTRYPOINT ["netspeeder.sh"]
