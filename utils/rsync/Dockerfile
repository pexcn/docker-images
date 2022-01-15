#
# Dockerfile for rsync
#

# alpine-based image cannot set "use chroot = yes", so based on debian:bullseye-slim
# reference:
#   https://stackoverflow.com/a/64739747
#   https://stackoverflow.com/a/60816190
FROM debian:bullseye-slim
LABEL maintainer="pexcn <i@pexcn.me>"

RUN apt-get update \
  && apt-get install --no-install-recommends -y cron rsync \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN rm -f /etc/cron.*/*

COPY rsync.sh /usr/local/bin/
COPY rsyncd.conf /etc/
COPY --chmod=600 rsyncd.secrets /etc/

ENV ENABLE_DAEMON=0
ENV CRONTAB=

ENTRYPOINT ["rsync.sh"]
