#
# Dockerfile for speedtest-go
#

#
# Build stage
#
FROM golang:alpine AS builder

RUN apk update \
  && apk add --no-cache --virtual .build-deps git gcc ca-certificates libc-dev

ARG VERSION=v1.1.3
RUN git clone https://github.com/librespeed/speedtest-go.git --branch $VERSION \
  && cd speedtest-go \
  && go build -ldflags "-w -s" -trimpath -o speedtest main.go \
  && mkdir /app \
  && cp -r assets speedtest settings.toml /app/ \
  && cd .. \
  && rm -r speedtest-go

RUN apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine

RUN apk update \
  && apk add --no-cache ca-certificates

COPY --from=builder /app/ /app/
COPY assets /app/assets/
COPY entrypoint.sh /app/

RUN apk add --no-cache libcap \
  && rm -rf /var/cache/apk/*
RUN setcap cap_net_bind_service+ep /app/speedtest
RUN chown nobody:nobody /app /app/assets

ENV TITLE="LibreSpeed"
ENV ADDR=
ENV PORT=

EXPOSE 8989
USER nobody
ENTRYPOINT ["/app/entrypoint.sh"]
