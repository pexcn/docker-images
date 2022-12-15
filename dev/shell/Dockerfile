#
# Dockerfile for Shell script development environment
#

FROM pexcn/docker-images:dev
LABEL maintainer="pexcn <i@pexcn.me>"

ARG SHELLCHECK_VER=v0.9.0
RUN case "$(dpkg --print-architecture)" in \
       amd64) arch="x86_64";; \
       *) arch="aarch64";; \
    esac \
  && curl -L https://github.com/koalaman/shellcheck/releases/download/${SHELLCHECK_VER}/shellcheck-${SHELLCHECK_VER}.linux.${arch}.tar.xz | \
      tar xvfJ - -C /usr/local/bin/ shellcheck-${SHELLCHECK_VER}/shellcheck --strip-components 1
