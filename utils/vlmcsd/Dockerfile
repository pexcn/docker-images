#
# Dockerfile for vlmcsd
#

#
# Build stage
#
FROM alpine AS builder

RUN apk update \
  && apk add --no-cache --virtual .build-deps build-base git

ARG VERSION=svn1113
RUN git clone https://github.com/Wind4/vlmcsd.git --branch $VERSION --recurse-submodules -j2 \
  && cd vlmcsd \
  && make vlmcsd -j$(nproc) VLMCSD_VERSION=$VERSION CFLAGS="-O3 -DFULL_INTERNAL_DATA" \
  && mkdir /app \
  && cp -r bin etc /app \
  && cd .. \
  && rm -r vlmcsd

RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

COPY --from=builder /app/ /app/

EXPOSE 1688
USER nobody
ENTRYPOINT ["/app/bin/vlmcsd", "-i", "/app/etc/vlmcsd.ini", "-e", "-D"]
