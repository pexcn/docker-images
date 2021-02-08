FROM pexcn/docker-images:stretch
MAINTAINER pexcn <i@pexcn.me>

# restore current user as root
USER root

# install padavan buildroot dependencies
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    autoconf automake autopoint build-essential make gcc libtool \
    bison flex bzip2 git gawk gettext patch pkg-config texinfo \
    libltdl-dev libgmp3-dev libmpc-dev libmpfr-dev zlib1g-dev \
    kmod automake1.11 cpio \
  && rm -rf /var/lib/apt/lists/*

# set current user
USER pexcn
