#
# Dockerfile for buster-kernel
#

FROM pexcn/docker-images:buster
LABEL maintainer="pexcn <i@pexcn.me>"

# install kernel depends
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      build-essential fakeroot kernel-wedge libncurses5-dev lsb-release quilt \
  && apt-get build-dep linux -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# set non-root user
USER builder
WORKDIR /home/builder

# setup ccache
#RUN ccache -M 20G
RUN echo "max_size = 20G" | sudo tee -a /etc/ccache.conf
ENV USE_CCACHE=1
