#
# Dockerfile for iperf
#

FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

RUN apk update \
  && apk add --no-cache iperf \
  && rm -rf /var/cache/apk/*

ENTRYPOINT ["/usr/bin/iperf"]
CMD ["--version"]
