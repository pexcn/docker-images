#
# Dockerfile for iperf & iperf3
#

FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

RUN apk update \
  && apk add --no-cache iperf iperf3 \
  && rm -rf /var/cache/apk/*

CMD ["/usr/bin/iperf", "--version"]
