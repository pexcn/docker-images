FROM pexcn/docker-images:stretch

# restore current user as root
USER root

# install lineageos buildroot dependencies
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    bc bison build-essential ccache curl flex g++-multilib gcc-multilib \
    git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev \
    lib32z1-dev liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev \
    libwxgtk3.0-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool \
    squashfs-tools xsltproc openjdk-8-jdk zip unzip zlib1g-dev \
    libc6-dev-i386 x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev \
  && rm -rf /var/lib/apt/lists/*

# setup repo
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo \
  && chmod a+x /usr/local/bin/repo

# set current user
USER pexcn

# sync lineageos sources
RUN mkdir ~/lineageos && cd ~/lineageos \
  && repo init -u https://github.com/LineageOS/android.git -b cm-14.1 --depth 1 \
  && repo sync -j8
