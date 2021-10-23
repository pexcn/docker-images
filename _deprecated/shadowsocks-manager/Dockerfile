#
# Dockerfile for shadowsocks-manager
#

FROM node:12-alpine
LABEL maintainer="pexcn <i@pexcn.me>"

RUN npm i -g shadowsocks-manager@0.36.68 --unsafe-perm \
  && npm cache clean --force

EXPOSE 8080
CMD ["ssmgr"]
