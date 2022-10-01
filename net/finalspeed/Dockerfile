#
# Dockerfile for finalspeed
#

#
# Build stage
#
FROM alpine AS builder

ARG VERSION=20221002
RUN apk update \
  && apk add --no-cache --virtual .build-deps curl \
  && mkdir finalspeed \
  && curl -sSL https://github.com/pexcn/finalspeed/releases/download/${VERSION}/finalspeed.tar.gz | tar -zxvf - -C finalspeed \
  && cd finalspeed \
  && mv FinalSpeedClient-*.jar fsc.jar \
  && mv FinalSpeedServer-*.jar fss.jar \
  && cd - \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine:3.16
LABEL maintainer="pexcn <i@pexcn.me>"

RUN apk update \
  && apk add --no-cache openjdk8 libpcap iptables openrc xvfb-run tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder /finalspeed/ /fs/
COPY *.json /fs/
COPY finalspeed.sh /usr/local/bin/

WORKDIR /fs
ENTRYPOINT ["finalspeed.sh"]
CMD ["server"]
