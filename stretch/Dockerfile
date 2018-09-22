FROM buildpack-deps:stretch

# make apt non-interactive
RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90non-interactive \
  && echo 'DPkg::Options "--force-confnew";' >> /etc/apt/apt.conf.d/90non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# install base dependencies
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    net-tools netcat unzip zip bzip2 tar gzip gnupg curl wget \
    git locales sudo ca-certificates nano time parallel

# set timezone to Asia/Shanghai by default
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# use unicode
RUN locale-gen C.UTF-8 || true
ENV LANG=C.UTF-8

# set up git
RUN git config --global user.name "pexcn" \
  && git config --global user.email "i@pexcn.me" \
  && git config --global color.ui auto \
  && git config --global core.editor nano \
  && git config --global log.date iso

# create user
RUN groupadd --gid 2077 pexcn \
  && useradd --uid 2077 --gid pexcn --shell /bin/bash --create-home pexcn \
  && echo 'pexcn ALL=NOPASSWD: ALL' >> /etc/sudoers.d/50-pexcn \
  && echo 'Defaults    env_keep += "DEBIAN_FRONTEND"' >> /etc/sudoers.d/env_keep

USER pexcn

CMD ["/bin/bash"]
