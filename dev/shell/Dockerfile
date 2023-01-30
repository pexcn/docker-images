#
# Dockerfile for Shell script development environment
#

FROM pexcn/docker-images:dev
LABEL maintainer="pexcn <pexcn97@gmail.com>"

# install packages
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      bzip2 gzip tar xz-utils zip unzip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# shellcheck
ARG SHELLCHECK_VER=v0.9.0
RUN case "$(dpkg --print-architecture)" in \
       amd64) arch="x86_64";; \
       *) arch="aarch64";; \
    esac \
  && curl -L https://github.com/koalaman/shellcheck/releases/download/${SHELLCHECK_VER}/shellcheck-${SHELLCHECK_VER}.linux.${arch}.tar.xz | \
      tar xvfJ - -C /usr/local/bin/ shellcheck-${SHELLCHECK_VER}/shellcheck --strip-components 1
