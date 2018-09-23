FROM pexcn/docker-images:stretch

# restore current user as root
USER root

# install openwrt buildroot dependencies
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    automake autoconf gcc g++ make libtool build-essential \
    ccache file git patch curl fakeroot quilt gawk gettext \
    pkg-config python libssl-dev libncurses5-dev zlib1g-dev \
    time groff help2man rpm texinfo systemd util-linux \
    libcap-ng-dev libattr1-dev libpam0g-dev libpsl-dev \
    libpython3-dev \
  && rm -rf /var/lib/apt/lists/*

# set current user
USER pexcn
