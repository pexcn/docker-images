#
# Dockerfile for Go language development environment
#

FROM pexcn/docker-images:dev
LABEL maintainer="pexcn <pexcn97@gmail.com>"

ENV PATH=/usr/local/go/bin:$PATH
ENV GOTOOLCHAIN=local
ENV GOLANG_VERSION=1.23.0

RUN curl https://dl.google.com/go/go${GOLANG_VERSION}.linux-$(dpkg --print-architecture).tar.gz | tar zxv -C /usr/local
