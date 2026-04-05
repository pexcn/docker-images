#
# Dockerfile for nezha
#

#
# Build stage
#
FROM golang:1.26-alpine AS builder

ARG DASHBOARD_VER=v2.0.7
ARG SWAG_VER=v1.16.6
RUN apk add --no-cache --virtual .build-deps git bash yq curl gcc musl-dev \
  && git clone https://github.com/naiba/nezha.git --branch $DASHBOARD_VER \
  && cd nezha \
  && ./script/fetch-frontends.sh \
  # TODO: country.mmdb
  && go install github.com/swaggo/swag/cmd/swag@${SWAG_VER} \
  && swag init --pd -d cmd/dashboard -g main.go -o cmd/dashboard/docs \
  && env CGO_ENABLED=1 go build -v -trimpath -mod=readonly -tags "go_json,musl" \
      -ldflags="-s -w -buildid= -X github.com/nezhahq/nezha/service/singleton.Version=${DASHBOARD_VER} -extldflags '-static -fpic -Wl,--build-id=none'" \
      ./cmd/dashboard \
  && install dashboard /usr/local/bin/ \
  && cd - \
  && rm -r nezha \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine:3.23
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk add --no-cache ca-certificates tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder /usr/local/bin/dashboard /usr/local/bin/

RUN mkdir -p /opt/nezha \
  && chown -R nobody:nobody /opt/nezha
WORKDIR /opt/nezha
USER nobody
EXPOSE 8008
ENTRYPOINT ["dashboard"]
