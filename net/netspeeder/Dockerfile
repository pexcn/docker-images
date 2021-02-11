#
# Dockerfile for netspeeder
#

#
# Build stage
#
FROM alpine AS builder

# add depends
RUN apk update \
  && apk add --no-cache --virtual .build-deps build-base libpcap-dev libnet-dev git

# build
ENV VERSION=84eea2e9750c6f4645bd4ea099fdab5239b7a742
RUN git clone https://github.com/pexcn/netspeeder.git \
  && cd netspeeder \
  && git checkout $VERSION \
  && make \
  && make install DESTDIR="/app" \
  && cd .. \
  && rm -r netspeeder

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
  && apk add --no-cache libpcap-dev libnet-dev \
  && rm -rf /var/cache/apk/*

COPY --from=builder /app/bin/netspeeder /app/netspeeder

USER root
ENTRYPOINT ["/app/netspeeder"]
