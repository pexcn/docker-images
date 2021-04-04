#
# Dockerfile for vlmcsd
#

#
# Build stage
#
FROM alpine AS builder

# depends
RUN apk update \
  && apk add --no-cache --virtual .build-deps build-base git

# build
ARG VERSION=svn1113
RUN git clone https://github.com/Wind4/vlmcsd.git --branch $VERSION --recurse-submodules -j2 vlmcsd-src \
  && cd vlmcsd-src \
  && make -j$(nproc) CFLAGS="-O3 -DFULL_INTERNAL_DATA" \
  && cp bin/vlmcs bin/vlmcsd etc/vlmcsd.ini / \
  && make clean \
  && cd .. \
  && rm -r vlmcsd-src

# clean
RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

COPY --from=builder /vlmcs /app/
COPY --from=builder /vlmcsd /app/
COPY --from=builder /vlmcsd.ini /app/

USER nobody
EXPOSE 1688/tcp
ENTRYPOINT /app/vlmcsd -i /app/vlmcsd.ini -e -D
