#
# Dockerfile for rng-tools
#

FROM alpine
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add --no-cache rng-tools \
  && rm -rf /var/cache/apk/*

ENTRYPOINT ["rngd", "-f"]
