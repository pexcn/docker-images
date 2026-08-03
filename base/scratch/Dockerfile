#
# Dockerfile for scratch base image
#

FROM pexcn/docker-images:alpine AS rootfs

FROM scratch
LABEL maintainer="pexcn <pexcn97@gmail.com>"

COPY --from=rootfs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=rootfs /usr/share/zoneinfo /usr/share/zoneinfo

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
