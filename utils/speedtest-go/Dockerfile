#
# Dockerfile for speedtest-go
#

#
# Build stage
#
FROM golang:alpine AS builder

# build
ARG VERSION=v1.1.2
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
ENV PORT=80
ENV PASSWORD="FREEHK"

# add depends
RUN apk update \
  && apk add --no-cache ca-certificates \
  && rm -rf /var/cache/apk/*

# set timezone
ENV TZ=Asia/Taipei
RUN apk update \
  && apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder /app/assets /app/assets
COPY --from=builder /app/speedtest-go /app/speedtest-go
COPY --from=builder /app/settings.toml /app/settings.toml
COPY assets-override /app/assets
COPY entrypoint.sh /app/entrypoint.sh

# fix permissions
RUN apk update \
  && apk add --no-cache libcap \
  && rm -rf /var/cache/apk/* \
  && setcap cap_net_bind_service+ep /app/speedtest-go \
  && chown nobody:nobody /app /app/assets
USER nobody

ENTRYPOINT ["/app/entrypoint.sh"]
