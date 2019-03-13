FROM pexcn/docker-images:stretch

# restore current user as root
USER root

# install linux kernel buildroot dependencies
RUN apt-get update \
  && apt-get install --no-install-recommends -y build-essential libncurses5-dev \
    fakeroot lsb-release quilt \
  && apt-get install --no-install-recommends -y -t stretch-backports kernel-wedge \
  && apt-get build-dep linux -y \
  && rm -rf /var/lib/apt/lists/*

# set current user
USER pexcn
