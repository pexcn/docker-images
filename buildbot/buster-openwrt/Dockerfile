#
# Dockerfile for buster-openwrt
#

FROM pexcn/docker-images:buster
LABEL maintainer="pexcn <pexcn97@gmail.com>"

# install openwrt depends
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      asciidoc autoconf automake bc binutils build-essential \
      bzip2 ccache curl fakeroot fastjar file flex g++ gawk \
      gcc gettext git help2man intltool libattr1-dev libelf-dev \
      libncurses5-dev libssl-dev libtool make patch perl-modules \
      pkg-config python python2-dev python3 quilt rsync texinfo \
      texlive time unzip util-linux wget xmlto xsltproc xz-utils \
      zlib1g-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# set non-root user
USER builder
WORKDIR /home/builder

# set git configs
RUN git config --global user.name "OpenWrt Builder" \
  && git config --global user.email "buster-openwrt@ovvo.uk"

# install po2lmo
RUN git clone https://github.com/openwrt-dev/po2lmo.git --single-branch -b master \
  && cd po2lmo \
  && make \
  && sudo make install \
  && cd .. \
  && rm -r po2lmo

# setup ccache
#RUN ccache -M 20G
RUN echo "max_size = 20G" | sudo tee -a /etc/ccache.conf
ENV USE_CCACHE=1
