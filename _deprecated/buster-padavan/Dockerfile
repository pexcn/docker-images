#
# Dockerfile for buster-padavan
#

FROM pexcn/docker-images:buster
LABEL maintainer="pexcn <pexcn97@gmail.com>"

# install padavan depends
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      autoconf automake automake1.11 autopoint bison \
      build-essential bzip2 ccache cpio flex gawk gcc \
      gettext git kmod libgmp3-dev libltdl-dev libmpc-dev \
      libmpfr-dev libtool make patch pkg-config texinfo \
      xz-utils zlib1g-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# set non-root user
USER builder
WORKDIR /home/builder

# setup ccache
#RUN ccache -M 20G
RUN echo "max_size = 20G" | sudo tee -a /etc/ccache.conf
ENV USE_CCACHE=1
