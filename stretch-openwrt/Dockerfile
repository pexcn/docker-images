FROM pexcn/docker-images:stretch

# restore current user as root
USER root

# install openwrt buildroot dependencies
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    automake autoconf gcc g++ make libtool build-essential \
    file git patch curl fakeroot quilt gawk gettext \
    pkg-config python libssl-dev libncurses5-dev zlib1g-dev \
    asciidoc bc binutils bzip2 fastjar flex util-linux \
    libgtk2.0-dev intltool jikespg genisoimage perl-modules \
    python-dev libpython-dev rsync sdcc unzip xsltproc \
    time groff help2man rpm texinfo libattr1-dev texlive \
    libelf-dev xmlto \
  && rm -rf /var/lib/apt/lists/*

# set current user
USER pexcn
