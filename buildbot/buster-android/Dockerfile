#
# Dockerfile for buster-android
#

FROM pexcn/docker-images:buster
LABEL maintainer="pexcn <pexcn97@gmail.com>"

# install android depends
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      git-core gnupg flex bison build-essential \
      zip curl zlib1g-dev gcc-multilib g++-multilib \
      libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev \
      libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils \
      xsltproc unzip fontconfig ccache \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# setup repo
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo \
  && chmod a+x /usr/local/bin/repo

# set non-root user
USER builder
WORKDIR /home/builder

# set git configs
RUN git config --global user.name "Android Builder" \
  && git config --global user.email "buster-android@ovvo.uk"

# setup ccache
#RUN ccache -M 20G
RUN echo "max_size = 20G" | sudo tee -a /etc/ccache.conf
ENV USE_CCACHE=1
