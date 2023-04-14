#
# Dockerfile for Python language development environment
#

FROM pexcn/docker-images:dev
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      python3 python3-pip python-is-python3 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
