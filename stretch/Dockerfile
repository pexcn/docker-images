FROM buildpack-deps:stretch

# make apt non-interactive
RUN echo 'APT::Get::Assume-Yes "true";' > /etc/apt/apt.conf.d/90non-interactive \
  && echo 'DPkg::Options "--force-confnew";' >> /etc/apt/apt.conf.d/90non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# install base dependencies and upgrade all packages
RUN apt-get update \
  && apt-get install --no-install-recommends -y apt-utils
RUN apt-get install --no-install-recommends -y \
    locales sudo ca-certificates curl wget \
    net-tools netcat nano gnupg parallel \
    bzip2 gzip tar xz-utils zip unzip \
  && apt-get dist-upgrade -y \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# set timezone to Asia/Shanghai by default
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# use unicode
RUN locale-gen C.UTF-8 || true
ENV LANG=C.UTF-8

# create user
RUN groupadd --gid 2077 pexcn \
  && useradd --uid 2077 --gid pexcn --shell /bin/bash --create-home pexcn \
  && echo 'pexcn ALL=NOPASSWD: ALL' >> /etc/sudoers.d/50-pexcn \
  && echo 'Defaults    env_keep += "DEBIAN_FRONTEND"' >> /etc/sudoers.d/env_keep

# set current user
USER pexcn

CMD ["/bin/bash"]
