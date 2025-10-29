#
# Dockerfile for trojan
#

#
# Build stage
#
FROM alpine AS builder

RUN apk update \
  && apk add --no-cache --virtual .build-deps build-base cmake git \
      boost-dev openssl-dev mariadb-connector-c-dev \
      boost-static openssl-libs-static mariadb-static zlib-static

ARG VERSION=v1.16.0
RUN git clone https://github.com/trojan-gfw/trojan.git --branch $VERSION \
  && cd trojan \
  && echo "target_link_libraries(trojan z)" >> CMakeLists.txt \
  && cmake -DCMAKE_INSTALL_PREFIX="/app" \
      -DFORCE_TCP_FASTOPEN=ON \
      -DCMAKE_CXX_FLAGS="-static" \
      -DBoost_USE_STATIC_LIBS=ON \
      -DOPENSSL_USE_STATIC_LIBS=ON \
      -DMYSQL_LIBRARY="/usr/lib/libmysqlclient.a" \
      . \
  && make -j$(nproc) \
  && make install/strip \
  && make clean \
  && cd .. \
  && rm -r trojan

RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <pexcn97@gmail.com>"

COPY --from=builder /app/bin/ /usr/local/bin/
COPY --from=builder /app/etc/ /etc/

# allow bind port less than 1024
RUN apk add --no-cache libcap \
  && rm -rf /var/cache/apk/*
RUN setcap cap_net_bind_service+ep /usr/local/bin/trojan

USER nobody
ENTRYPOINT ["trojan", "-c", "/etc/trojan/config.json"]
