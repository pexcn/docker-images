#
# Dockerfile for chisel
#

FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

ENV VERSION=1.7.4
RUN apk update \
  && apk add --no-cache ca-certificates \
  && mkdir /app \
  && cd /app \
  && wget -O chisel.gz https://github.com/jpillora/chisel/releases/download/v$VERSION/chisel_${VERSION}_linux_amd64.gz \
  && gunzip chisel.gz \
  && chmod +x chisel

# set timezone
ENV TZ=Asia/Taipei
RUN apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

USER nobody
ENTRYPOINT ["/app/chisel"]
