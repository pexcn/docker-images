#
# Dockerfile for speedtest-go
#

#
# Build stage
#
FROM golang:alpine AS builder

# build
ARG VERSION=v1.1.3
RUN apk update \
  && apk add --no-cache --virtual .build-deps git gcc ca-certificates libc-dev \
  && git clone https://github.com/librespeed/speedtest-go.git --branch $VERSION /tmp/speedtest-go \
  && cd /tmp/speedtest-go \
  && go build -ldflags "-w -s" -trimpath -o speedtest main.go

# install
RUN mkdir /app \
  && cp -r /tmp/speedtest-go/assets /app \
  && cp /tmp/speedtest-go/speedtest /app/speedtest-go \
  && cp /tmp/speedtest-go/settings.toml /app/settings.toml

# clean
RUN apk del .build-deps \
  && rm -rf /var/cache/apk/* \
  && rm -r /tmp/speedtest-go

#
# Runtime stage
#
FROM alpine

ENV TITLE="LibreSpeed"
ENV ADDR=
ENV PORT=80

# add depends
RUN apk update \
  && apk add --no-cache ca-certificates

COPY --from=builder /app/assets /app/assets
COPY --from=builder /app/speedtest-go /app/speedtest-go
COPY --from=builder /app/settings.toml /app/settings.toml
COPY assets-override /app/assets
COPY entrypoint.sh /app/entrypoint.sh

# allow bind port less than 1024
RUN apk add --no-cache libcap \
  && rm -rf /var/cache/apk/*
RUN setcap cap_net_bind_service+ep /app/speedtest-go
# fix permissions
RUN chown nobody:nobody /app /app/assets

EXPOSE 8989
USER nobody
ENTRYPOINT ["/app/entrypoint.sh"]
