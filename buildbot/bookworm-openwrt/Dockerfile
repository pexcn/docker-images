#
# Dockerfile for bookworm-openwrt
#

FROM pexcn/docker-images:bookworm
LABEL maintainer="pexcn <pexcn97@gmail.com>"

# install openwrt depends
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      build-essential clang flex bison g++ gawk gcc-multilib g++-multilib \
      gettext git libncurses-dev libssl-dev python3-distutils rsync unzip \
      zlib1g-dev zstd file wget ccache rename \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# set non-root user
USER builder
WORKDIR /builder

# set git configs
RUN git config --global user.name "OpenWrt Builder" \
  && git config --global user.email "buster-openwrt@ovvo.uk"

# install po2lmo
RUN git clone https://github.com/openwrt-dev/po2lmo.git --single-branch -b master \
  && cd po2lmo \
  && make \
  && sudo make install \
  && cd - \
  && rm -r po2lmo

# setup ccache
RUN echo "max_size = 20G" | sudo tee -a /etc/ccache.conf
ENV USE_CCACHE=1
