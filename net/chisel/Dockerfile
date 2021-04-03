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
  && if [[ -n "$TARGETOS" && -n "$TARGETARCH" ]]; then \
       wget -O chisel.gz https://github.com/jpillora/chisel/releases/download/v$VERSION/chisel_${VERSION}_${TARGETOS}_${TARGETARCH}.gz; \
     else \
       wget -O chisel.gz https://github.com/jpillora/chisel/releases/download/v$VERSION/chisel_${VERSION}_linux_amd64.gz; \
     fi \
  && gunzip chisel.gz \
  && chmod +x chisel

# allow bind port less than 1024
RUN apk add --no-cache libcap \
  && rm -rf /var/cache/apk/*
RUN setcap cap_net_bind_service+ep /app/chisel

USER nobody
ENTRYPOINT ["/app/chisel"]
