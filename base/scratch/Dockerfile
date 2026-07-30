#
# Dockerfile for scratch base image
#

FROM alpine:3.24 AS builder
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk add --no-cache tzdata ca-certificates

FROM scratch
LABEL maintainer="pexcn <pexcn97@gmail.com>"

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
