#
# Dockerfile for vlmcsd
#

FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

# get binary
ENV VERSION=svn1113
RUN cd /tmp \
  && wget https://github.com/Wind4/vlmcsd/releases/download/$VERSION/binaries.tar.gz \
  && tar -zxvf binaries.tar.gz binaries/Linux/intel/static/vlmcsd-x64-musl-static --strip-components 4 \
  && mkdir /app && mv vlmcsd-x64-musl-static /app/vlmcsd \
  && chown root:root /app/vlmcsd \
  && rm binaries.tar.gz

# copy config
COPY vlmcsd.ini /app/vlmcsd.ini

# set timezone
ENV TZ=Asia/Taipei
RUN apk update \
  && apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

USER nobody
ENTRYPOINT /app/vlmcsd -i /app/vlmcsd.ini -e -D