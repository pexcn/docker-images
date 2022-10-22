#
# Dockerfile for development base environment
#

FROM debian:bullseye-slim
LABEL maintainer="pexcn <i@pexcn.me>"

# install packages
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      apt-utils dialog \
  && apt-get install --no-install-recommends -y \
      bash-completion ca-certificates curl wget net-tools \
      git locales procps nano tree file \
  && apt-get install --no-install-recommends -y \
      openssh-server \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# create non-root user
ARG USER_NAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd $USER_NAME --gid $USER_GID \
  && useradd $USER_NAME --uid $USER_UID --gid $USER_NAME --shell /bin/bash --create-home --home-dir /vscode

# set timezone
ENV TZ=Asia/Taipei
RUN ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime

# set locales
RUN sed -i '/^# en_US.UTF-8 UTF-8/s/^# //' /etc/locale.gen \
  && sed -i '/^# zh_CN.UTF-8 UTF-8/s/^# //' /etc/locale.gen \
  && sed -i '/^# zh_TW.UTF-8 UTF-8/s/^# //' /etc/locale.gen \
  && locale-gen \
  && update-locale LANG=zh_CN.UTF-8

# set dotfiles
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

ENV GIT_USER=
ENV GIT_EMAIL=
ENV ENABLE_SSHD=
ENV SSH_PORT=

COPY function.sh /usr/local/lib/
COPY entrypoint.sh /usr/local/bin/

ENTRYPOINT ["entrypoint.sh"]
