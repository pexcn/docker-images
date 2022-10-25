#
# Dockerfile for C/C++ language development environment
#

FROM pexcn/docker-images:dev
LABEL maintainer="pexcn <i@pexcn.me>"

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      gcc libc6-dev gdb g++ \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
