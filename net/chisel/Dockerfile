#
# Dockerfile for chisel
#

FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

# download binary
ARG VERSION=1.7.4
ARG TARGETOS
ARG TARGETARCH
RUN apk update \
  && apk add --no-cache ca-certificates \
  && mkdir /app \
  && cd /app \
  && wget -O chisel.gz https://github.com/jpillora/chisel/releases/download/v$VERSION/chisel_${VERSION}_${TARGETOS}_${TARGETARCH}.gz \
  && gunzip chisel.gz \
  && chmod +x chisel

# set timezone
ENV TZ=Asia/Taipei
RUN apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

USER nobody
ENTRYPOINT ["/app/chisel"]
