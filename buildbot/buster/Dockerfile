FROM debian:buster-slim
MAINTAINER pexcn <i@pexcn.me>

# apt non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# add base dependencies
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      apt-utils dialog \
  && apt-get install --no-install-recommends -y \
      ca-certificates curl wget git locales sudo \
      bzip2 gzip tar xz-utils zip unzip

# upgrade all packages
RUN apt-get dist-upgrade -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# set timezone
ENV TZ=Asia/Taipei
RUN ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime

# set locales
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8

# create user
RUN groupadd builder --system \
  && useradd builder --system --no-log-init --create-home --gid builder --shell /bin/bash

# set builder group run sudo without password
RUN echo '%builder ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/50-builder

# keep environment variables for sudo
RUN echo 'Defaults env_keep += "DEBIAN_FRONTEND TZ LANG"' >> /etc/sudoers.d/env_keep
