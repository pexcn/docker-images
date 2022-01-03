#
# Dockerfile for rsync
#

# alpine-based image cannot set "use chroot = yes"
# so based on debian:bullseye-slim
# reference: https://stackoverflow.com/a/64739747
FROM debian:bullseye-slim
LABEL maintainer="pexcn <i@pexcn.me>"

RUN apt-get update \
  && apt-get install --no-install-recommends -y rsync \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY rsyncd.conf /etc/
COPY rsyncd.secrets /etc/

ENTRYPOINT ["rsync", "--daemon", "--no-detach"]
