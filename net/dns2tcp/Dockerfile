#
# Dockerfile for dns2tcp
#

#
# Build stage
#
FROM alpine AS builder

ARG VERSION=10ed687778f18d1b9c98bb51187a3a9086d3a0d9
RUN apk update \
  && apk add --no-cache --virtual .build-deps build-base linux-headers git \
  && git clone https://github.com/zfl9/dns2tcp.git \
  && cd dns2tcp \
  && git checkout $VERSION \
  && make -j$(nproc) EVCFLAGS="-w -O3" CFLAGS="-std=c99 -Wall -Wextra -O3 -static" \
  && make install \
  && make clean \
  && cd - \
  && rm -r dns2tcp \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder /usr/local/bin/dns2tcp /usr/local/bin/

# allow bind port less than 1024
RUN apk update \
  && apk add --no-cache libcap \
  && rm -rf /var/cache/apk/*
RUN setcap cap_net_bind_service+ep /app/dns2tcp

USER nobody
ENTRYPOINT ["dns2tcp"]
CMD ["-h"]
