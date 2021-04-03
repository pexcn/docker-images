#
# Dockerfile for vlmcsd
#

FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

# download binary
ARG TARGETPLATFORM
ARG VERSION=svn1113
RUN cd /tmp \
  && wget https://github.com/Wind4/vlmcsd/releases/download/$VERSION/binaries.tar.gz \
  && if [[ "$TARGETPLATFORM" == "linux/amd64" ]]; then \
       tar -zxvf binaries.tar.gz binaries/Linux/intel/static/vlmcsd-x64-musl-static --strip-components 4; \
     elif [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then \
       tar -zxvf binaries.tar.gz binaries/Linux/arm/little-endian/static/vlmcsd-armv7el-uclibc-static --strip-components 5; \
     else \
       tar -zxvf binaries.tar.gz binaries/Linux/intel/static/vlmcsd-x64-musl-static --strip-components 4; \
     fi \
  && mkdir /app && mv vlmcsd-* /app/vlmcsd \
  && chown root:root /app/vlmcsd \
  && rm binaries.tar.gz

COPY vlmcsd.ini /app/vlmcsd.ini

USER nobody
ENTRYPOINT /app/vlmcsd -i /app/vlmcsd.ini -e -D
