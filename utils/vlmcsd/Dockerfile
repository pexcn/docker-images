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
  && install bin/vlmcsd /usr/local/bin/ \
  && install -m 0644 etc/* /etc/ \
  && cd .. \
  && rm -r vlmcsd

RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

COPY --from=builder /usr/local/bin/vlmcsd /usr/local/bin/
COPY --from=builder /etc/vlmcsd.* /etc/

EXPOSE 1688
USER nobody
ENTRYPOINT ["vlmcsd", "-i", "/etc/vlmcsd.ini", "-e", "-D"]
