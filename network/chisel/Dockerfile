#
# Dockerfile for chisel
#

FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

ENV VERSION=1.7.4
ENV BIN_URL=https://github.com/jpillora/chisel/releases/download/v$VERSION/chisel_${VERSION}_linux_amd64.gz

# add depends
RUN apk update \
  && apk add --no-cache ca-certificates \
  && rm -rf /var/cache/apk/*

# get binary
WORKDIR /app
RUN wget -O chisel.gz $BIN_URL \
  && gunzip chisel.gz \
  && chmod +x chisel
WORKDIR /

USER nobody
ENTRYPOINT ["/app/chisel"]
