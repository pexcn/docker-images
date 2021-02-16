#
# Dockerfile for buster-openwrt
#

FROM pexcn/docker-images:buster
LABEL maintainer="pexcn <i@pexcn.me>"

# install openwrt depends
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      asciidoc autoconf automake bc binutils build-essential \
      bzip2 ccache curl fakeroot fastjar file flex g++ gawk \
      gcc gettext git help2man intltool libattr1-dev libelf-dev \
      libncurses5-dev libssl-dev libtool make patch perl-modules \
      pkg-config python python2-dev python3 quilt rsync texinfo \
      texlive time unzip util-linux wget xmlto xsltproc xz-utils \
      zlib1g-dev
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# set non-root user
USER builder

# set git configs
RUN git config --global user.name "OpenWrt Builder" \
  && git config --global user.email "openwrt-buildbot@pexcn.me"

# set ccache
# TODO...
