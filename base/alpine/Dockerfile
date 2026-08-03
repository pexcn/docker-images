#
# Dockerfile for alpine base image
#

FROM alpine:3.24 AS rootfs

RUN apk add --no-cache tzdata ca-certificates
RUN apk del --no-cache musl-utils

FROM scratch
LABEL maintainer="pexcn <pexcn97@gmail.com>"

COPY --from=rootfs / /

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
CMD ["/bin/sh"]
