#
# Dockerfile for transproxy
#

FROM alpine:3.18
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add --no-cache iproute2-minimal ipset iptables ip6tables \
  && rm -rf /var/cache/apk/*

ARG VERSION=v0.4.3
RUN apk update \
  && apk add --no-cache --virtual .build-deps git \
  && git clone https://github.com/pexcn/transproxy.git --branch $VERSION \
  && cd transproxy \
  && git checkout $VERSION \
  && install transproxy /usr/local/bin/ \
  && install transproxy6 /usr/local/bin/ \
  && cd - \
  && rm -r transproxy \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

COPY transproxy.sh /usr/local/bin/

ENV DISABLE_IPV6=0

ENTRYPOINT ["transproxy.sh"]
