#
# Dockerfile for iperf3
#

FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

RUN apk update \
  && apk add --no-cache iperf3 \
  && rm -rf /var/cache/apk/*

ENTRYPOINT ["/usr/bin/iperf3"]
CMD ["--version"]
