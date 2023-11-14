#
# Dockerfile for coremark
#

FROM debian:bookworm-slim
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apt-get update \
  && apt-get install --no-install-recommends -y git gcc make libc6-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY coremark-d5fad6bd094899101a4e5fd53af7298160ced6ab.tar.gz /srv/
COPY coremark.sh /usr/local/bin/

ENTRYPOINT ["coremark.sh"]
