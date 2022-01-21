#
# Dockerfile for nezha
#

#
# Build stage
#
FROM golang:1.17-alpine AS builder

ARG VERSION=v0.12.2
RUN apk update \
  && apk add --no-cache --virtual .build-deps git gcc musl-dev \
  && git clone https://github.com/naiba/nezha.git --branch $VERSION \
  && cd nezha \
  && cd cmd/agent && go build -ldflags "-w -s" -trimpath -o nezha-agent && cd ../.. \
  && cd cmd/dashboard && go build -ldflags "-w -s" -trimpath -o nezha-dashboard && cd ../.. \
  && cp cmd/agent/nezha-agent /usr/local/bin/ \
  && cp cmd/dashboard/nezha-dashboard /usr/local/bin/ \
  && cd .. \
  && rm -r nezha \
  && git clone https://github.com/naiba/nezha.git --branch $VERSION /srv \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <i@pexcn.me>"

RUN apk update \
  && apk add tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder /usr/local/bin/nezha-agent /usr/local/bin/
COPY --from=builder /usr/local/bin/nezha-dashboard /usr/local/bin/
COPY --from=builder /srv/ /srv/
COPY nezha.sh /usr/local/bin/
COPY config.yaml /srv/data/

RUN chown -R nobody:nobody /srv
USER nobody

ENV AGENT_MODE=0

WORKDIR /srv
VOLUME /srv/data
EXPOSE 8888 5555
ENTRYPOINT ["nezha.sh"]
