#
# Dockerfile for development isolation environment
#

FROM pexcn/docker-images:dev

# install packages
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      iputils-ping lrzsz \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# install tcping
RUN case "$(dpkg --print-architecture)" in \
       amd64) arch="amd64";; \
       *) arch="arm64";; \
    esac \
  && curl https://github.com/pexcn/share/raw/master/bin/tcping/tcping-${arch} -L -o /usr/local/bin/tcping \
  && chmod +x /usr/local/bin/tcping

# install docker
ARG DOCKER_VERSION=20.10.21
ARG COMPOSE_VERSION=v2.12.2
RUN case "$(dpkg --print-architecture)" in \
       amd64) arch="x86_64";; \
       *) arch="aarch64";; \
    esac \
  && curl https://download.docker.com/linux/static/stable/${arch}/docker-${DOCKER_VERSION}.tgz | \
      tar zxv -C /usr/local/bin/ docker/docker --strip-components 1 \
  && curl https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-${arch} -L -o /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose

# allow root login
RUN sed -i 's/^.*PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

COPY start.sh /usr/local/bin/

ENV ENABLE_SSHD=1
ENV SSH_PORT=2222
ENV USERNAME=user
ENV PASSWORD=password
ENV ROOT_PASSWORD=password
ENV DOCKER_GID=972

CMD ["start.sh"]
