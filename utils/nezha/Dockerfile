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
  && git clone https://github.com/nezhahq/nezha.git --branch $DASHBOARD_VER \
  && cd nezha \
  && ./script/fetch-frontends.sh \
  && curl -L https://ipinfo.io/data/free/country.mmdb?token=${IPINFO_TOKEN} -o pkg/geoip/geoip.db \
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

ARG TARGETARCH
ARG AGENT_VER=v2.0.2
RUN apk add --no-cache --virtual .build-deps git \
  && git clone https://github.com/nezhahq/agent.git --branch $AGENT_VER \
  && cd agent \
  && env CGO_ENABLED=0 go build -v -trimpath -mod=readonly \
      -ldflags="-s -w -buildid= -X github.com/nezhahq/agent/pkg/monitor.Version=${AGENT_VER} -X main.arch=${TARGETARCH}" \
      ./cmd/agent \
  && install agent /usr/local/bin/ \
  && cd - \
  && rm -r agent \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine:3.23
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk add --no-cache ca-certificates tzdata \
  && rm -rf /var/cache/apk/*

# make the agent to read information from /etc/os-release
RUN rm /etc/alpine-release

COPY --from=builder /usr/local/bin/dashboard /usr/local/bin/
COPY --from=builder /usr/local/bin/agent /usr/local/bin/
COPY nezha.sh /usr/local/bin/

RUN mkdir -p /opt/nezha \
  && chown -R nobody:nobody /opt/nezha
WORKDIR /opt/nezha
USER nobody
EXPOSE 8008
ENTRYPOINT ["nezha.sh"]
