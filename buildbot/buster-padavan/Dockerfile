#
# Dockerfile for buster-padavan
#

FROM pexcn/docker-images:buster
LABEL maintainer="pexcn <i@pexcn.me>"

# install padavan depends
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      autoconf automake automake1.11 autopoint bison \
      build-essential bzip2 cpio flex gawk gcc gettext \
      git kmod libgmp3-dev libltdl-dev libmpc-dev \
      libmpfr-dev libtool make patch pkg-config texinfo \
      xz-utils zlib1g-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# set non-root user
USER builder
WORKDIR /home/builder

# set git configs
RUN git config --global user.name "Padavan Builder" \
  && git config --global user.email "buildbot-buster-padavan@pexcn.me"

# set ccache
# TODO...