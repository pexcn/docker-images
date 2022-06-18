#
# Dockerfile for Rust language development environment
#

FROM rust:1.61-slim-bullseye
LABEL maintainer="pexcn <i@pexcn.me>"

# install packages
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      apt-utils dialog \
  && apt-get install --no-install-recommends -y \
      bash-completion curl wget net-tools git locales procps nano tree \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# create non-root user
ARG USER_NAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd $USER_NAME --gid $USER_GID \
  && useradd $USER_NAME --uid $USER_UID --gid $USER_NAME --shell /bin/bash --create-home

# set timezone
ENV TZ=Asia/Taipei
RUN ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime

# set locales
RUN sed -i '/^# en_US.UTF-8 UTF-8/s/^# //' /etc/locale.gen \
  && sed -i '/^# zh_CN.UTF-8 UTF-8/s/^# //' /etc/locale.gen \
  && sed -i '/^# zh_TW.UTF-8 UTF-8/s/^# //' /etc/locale.gen \
  && locale-gen \
  && update-locale LANG=zh_CN.UTF-8

# dotfiles
RUN git clone https://github.com/pexcn/dotfiles.git -b debian \
  && cd dotfiles \
  && ./install.sh root \
  && git config --global --unset user.name \
  && git config --global --unset user.email \
  && ./install.sh $USER_NAME \
  && su $USER_NAME -c "git config --global --unset user.name" \
  && su $USER_NAME -c "git config --global --unset user.email" \
  && cd - \
  && rm -rf dotfiles

COPY rust.sh /usr/local/bin/

ENTRYPOINT ["rust.sh"]
