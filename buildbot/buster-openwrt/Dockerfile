#
# Dockerfile for buster-openwrt
#

FROM pexcn/docker-images:buster
LABEL maintainer="pexcn <i@pexcn.me>"

# install openwrt depends
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      asciidoc automake autoconf bc build-essential \
      binutils bzip2 curl fastjar file fakeroot flex \
      git g++ gcc util-linux gawk help2man intltool \
      libelf-dev zlib1g-dev make libattr1-dev libncurses5-dev \
      libssl-dev libtool pkg-config patch perl-modules python \
      python2-dev python3 quilt rsync texinfo texlive time \
      unzip wget gettext xsltproc xmlto \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# set non-root user
USER builder

# set git configs
RUN git config --global user.name "OpenWrt Builder" \
  && git config --global user.email "openwrt-buildbot@pexcn.me"

# set ccache
# TODO...
