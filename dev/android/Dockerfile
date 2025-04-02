#
# Dockerfile for Android development environment
#

FROM pexcn/docker-images:dev
LABEL maintainer="pexcn <pexcn97@gmail.com>"

ARG CMDLINE_TOOLS_VER=13114758
ARG BUILD_TOOLS_VER=35.0.1
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH=/opt/cmdline-tools/bin:${ANDROID_HOME}/build-tools/${BUILD_TOOLS_VER}:$PATH

# install depends
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      openjdk-17-jdk \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# cmdline-tools
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_VER}_latest.zip -O cmdline-tools.zip \
  && unzip cmdline-tools.zip -d /opt \
  && rm cmdline-tools.zip

# build-tools
RUN yes | sdkmanager --sdk_root=$ANDROID_HOME --licenses \
  && sdkmanager --sdk_root=$ANDROID_HOME --install "build-tools;$BUILD_TOOLS_VER"
