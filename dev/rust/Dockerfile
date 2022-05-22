#
# Dockerfile for Rust language development environment
#

FROM rust:1.61-slim-bullseye

# create non-root user
ARG USER_NAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd $USER_NAME --gid $USER_GID \
  && useradd $USER_NAME --uid $USER_UID --gid $USER_NAME --shell /bin/bash --create-home

COPY rust.sh /usr/local/bin/

# TODO
#RUN apt-get update && apt-get install wget curl git -y

ENTRYPOINT ["rust.sh"]
