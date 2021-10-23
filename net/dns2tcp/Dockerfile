#
# Dockerfile for dns2tcp
#

#
# Build stage
#
FROM alpine AS builder

# depends
RUN apk update \
  && apk add --no-cache --virtual .build-deps build-base linux-headers git

# build
ARG VERSION=10ed687778f18d1b9c98bb51187a3a9086d3a0d9
RUN git clone https://github.com/zfl9/dns2tcp.git \
  && cd dns2tcp \
  && git checkout $VERSION \
  && make -j$(nproc) EVCFLAGS="-w -O3 -pipe" CFLAGS="-std=c99 -Wall -Wextra -O3 -pipe" \
  && make install DESTDIR="/app" \
  && make clean \
  && cd .. \
  && rm -r dns2tcp

# clean
RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

COPY --from=builder /app/dns2tcp /app/dns2tcp

# allow bind port less than 1024
RUN apk update \
  && apk add --no-cache libcap \
  && rm -rf /var/cache/apk/*
RUN setcap cap_net_bind_service+ep /app/dns2tcp

EXPOSE 5300/udp
USER nobody
ENTRYPOINT ["/app/dns2tcp"]
