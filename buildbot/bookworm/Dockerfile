#
# Dockerfile for bookworm
#

FROM debian:bookworm-slim
LABEL maintainer="pexcn <pexcn97@gmail.com>"

# apt non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# install base depends
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      apt-utils dialog \
  && apt-get install --no-install-recommends -y \
      ca-certificates curl wget git locales sudo tzdata procps \
      bzip2 gzip tar xz-utils zip unzip

# upgrade all packages
RUN apt-get dist-upgrade -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# set timezone
ENV TZ=Asia/Taipei
RUN ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime

# set locales
RUN sed -i '/en_US.UTF-8/s/^# //' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LC_COLLATE=C

# preferred use ipv4
RUN sed -i "s|#precedence ::ffff:0:0/96  100|precedence ::ffff:0:0/96  100|" /etc/gai.conf

# create user
RUN groupadd builder --gid 1001 \
  && useradd builder --uid 1001 --gid 1001 --shell /bin/bash --create-home --home-dir /builder

# set builder group run sudo without password
RUN echo '%builder ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/50-builder

# keep environment variables for sudo
RUN echo 'Defaults env_keep += "DEBIAN_FRONTEND TZ LANG LC_COLLATE"' >> /etc/sudoers.d/env_keep
