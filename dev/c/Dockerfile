#
# Dockerfile for C/C++ language development environment
#

FROM pexcn/docker-images:dev
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      gcc libc6-dev gdb g++ \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
