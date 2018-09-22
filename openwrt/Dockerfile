FROM pexcn/buildpack-deps:stretch

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    automake autoconf gcc g++ make libtool build-essential \
    ccache file git patch curl fakeroot quilt gawk gettext \
    pkg-config python libssl-dev libncurses5-dev zlib1g-dev \
  && rm -rf /var/lib/apt/lists/*
