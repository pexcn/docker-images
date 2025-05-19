#
# Dockerfile for bookworm-android
#

FROM pexcn/docker-images:bookworm
LABEL maintainer="pexcn <pexcn97@gmail.com>"

# install android depends
RUN apt-get update \
  # ref: https://source.android.com/docs/setup/start/requirements
  && apt-get install --no-install-recommends -y \
      git-core gnupg flex bison build-essential zip \
      curl zlib1g-dev libc6-dev-i386 x11proto-core-dev \
      libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils \
      xsltproc unzip fontconfig \
  # ref: https://wiki.lineageos.org/devices/munch/build/variant1/
  && apt-get install --no-install-recommends -y \
      g++-multilib gcc-multilib ccache bc git-lfs gperf \
      imagemagick protobuf-compiler python3-protobuf \
      lib32readline-dev libdw-dev libelf-dev libncurses5 \
      libncurses5-dev lz4 libsdl1.2-dev libssl-dev libxml2 \
      lzop pngcrush rsync schedtool squashfs-tools \
  && apt-get install --no-install-recommends -y \
      cpio python3 python-is-python3 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# setup repo
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo \
  && chmod a+x /usr/local/bin/repo

# set non-root user
USER builder
WORKDIR /builder

# set git configs
RUN git config --global user.name "Android Builder" \
  && git config --global user.email "buster-android@ovvo.uk"

# setup ccache
RUN echo "max_size = 20G" | sudo tee -a /etc/ccache.conf
ENV USE_CCACHE=1
