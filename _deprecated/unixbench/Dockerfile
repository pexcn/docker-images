#
# Dockerfile for unixbench
#

FROM debian:bullseye-slim
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apt-get update \
  && apt-get install --no-install-recommends -y make gcc libc6-dev \
      libtime-hires-perl locales \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
  && locale-gen en_US.UTF-8

COPY UnixBench-5.1.3-e477bc0.tar.gz /srv/
COPY unixbench.sh /usr/local/bin/

ENTRYPOINT ["unixbench.sh"]
