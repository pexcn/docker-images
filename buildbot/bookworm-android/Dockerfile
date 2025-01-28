#
# Dockerfile for bookworm-android
#

FROM pexcn/docker-images:bookworm
LABEL maintainer="pexcn <pexcn97@gmail.com>"

# install android depends
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      git-core gnupg flex bison build-essential zip \
      curl zlib1g-dev libc6-dev-i386 x11proto-core-dev \
      libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils \
      xsltproc unzip fontconfig \
  && apt-get install --no-install-recommends -y \
    ccache bc libssl-dev \
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
