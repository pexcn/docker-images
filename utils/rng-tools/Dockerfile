#
# Dockerfile for rng-tools
#

FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

RUN apk update \
  && apk add --no-cache rng-tools \
  && rm -rf /var/cache/apk/*

ENTRYPOINT ["/usr/sbin/rngd", "-f"]
