#
# Dockerfile for vlmcsd
#

FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

ENV VERSION=svn1113
ENV BIN_URL=https://github.com/Wind4/vlmcsd/releases/download/$VERSION/binaries.tar.gz
ENV TZ=Asia/Taipei

# add depends
RUN apk update \
  && apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

# get binary
WORKDIR /app
RUN wget $BIN_URL \
  && tar -zxvf binaries.tar.gz binaries/Linux/intel/static/vlmcsd-x64-musl-static --strip-components 4 \
  && mv vlmcsd-x64-musl-static vlmcsd \
  && chown root:root vlmcsd \
  && rm binaries.tar.gz
WORKDIR /

# copy config
COPY vlmcsd.ini /app/vlmcsd.ini

USER nobody
EXPOSE 1688
ENTRYPOINT /app/vlmcsd -i /app/vlmcsd.ini -e -D
