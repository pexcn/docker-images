#
# Dockerfile for pptpd
#

FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

# add depends
RUN apk update \
  && apk add --no-cache pptpd ppp iptables \
  && rm -rf /var/cache/apk/*

# copy config
COPY pptpd.conf /etc/pptpd.conf
COPY pptpd-options /etc/ppp/pptpd-options
COPY chap-secrets /etc/ppp/chap-secrets
COPY entrypoint.sh /app/entrypoint.sh

EXPOSE 1723/tcp
ENTRYPOINT ["/app/entrypoint.sh"]
