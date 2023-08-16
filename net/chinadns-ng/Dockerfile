#
# Dockerfile for chinadns-ng
#

#
# Build stage
#
FROM alpine AS builder

ARG VERSION=33e75ed57a8dd152ab67451216384ca1b23b9d66
RUN apk update \
  && apk add --no-cache --virtual .build-deps build-base linux-headers git \
  && git clone https://github.com/zfl9/chinadns-ng.git \
  && cd chinadns-ng \
  && git checkout $VERSION \
  && make -j$(nproc) \
  && make install \
  && make clean \
  && cd - \
  && rm -r chinadns-ng \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add --no-cache tzdata curl ipset \
  && rm -rf /var/cache/apk/*

RUN curl -sSL --create-dirs --output-dir /etc/chinadns-ng \
  -O https://github.com/pexcn/daily/raw/gh-pages/chnroute/chnroute.txt \
  -O https://github.com/pexcn/daily/raw/gh-pages/chnroute/chnroute6.txt \
  -O https://github.com/pexcn/daily/raw/gh-pages/gfwlist/gfwlist.txt \
  -O https://github.com/pexcn/daily/raw/gh-pages/chinalist/chinalist.txt

COPY --from=builder /usr/local/bin/chinadns-ng /usr/local/bin/
COPY chinadns-ng.sh /usr/local/bin/

ENV RULES_UPDATE_INTERVAL=0

ENTRYPOINT ["chinadns-ng.sh"]
CMD ["--help"]
