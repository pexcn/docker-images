#
# Dockerfile for nginx
#

FROM alpine:3.18
LABEL maintainer="pexcn <pexcn97@gmail.com>"

ARG NGINX_VER=1.24.0-r6
RUN apk update \
  && apk add --no-cache tzdata \
      nginx=$NGINX_VER \
      nginx-mod-stream=$NGINX_VER \
  && rm -rf /var/cache/apk/*

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
