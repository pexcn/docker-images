#
# Dockerfile for trojan
#

#
# Build stage
#
FROM alpine AS builder

# depends
RUN apk update \
  && apk add --no-cache --virtual .build-deps build-base \
      cmake boost-dev openssl-dev mariadb-connector-c-dev git

# build
ARG VERSION=v1.16.0
RUN git clone https://github.com/trojan-gfw/trojan.git --branch $VERSION \
  && cd trojan \
  && cmake -DCMAKE_INSTALL_PREFIX=/app . \
  && make -j$(nproc) \
  && make install/strip \
  && make clean \
  && cd .. \
  && rm -r trojan

# clean
RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

RUN apk update \
  && apk add --no-cache libstdc++ boost-system boost-program_options mariadb-connector-c

COPY --from=builder /app/bin/ /app/bin/
COPY --from=builder /app/etc/ /app/etc/

# allow bind port less than 1024
RUN apk add --no-cache libcap \
  && rm -rf /var/cache/apk/*
RUN setcap cap_net_bind_service+ep /app/bin/trojan

EXPOSE 443
USER nobody
ENTRYPOINT ["/app/bin/trojan", "-c", "/app/etc/trojan/config.json"]
