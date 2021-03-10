#
# Dockerfile for dsm-open-vm-tools
#

FROM debian:buster-slim

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
      openssh-client open-vm-tools \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh
COPY shutdown.sh /sbin/shutdown

CMD [ "/start.sh" ]
