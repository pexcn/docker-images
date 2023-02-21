#
# Dockerfile for udpspeeder
#

#
# Build stage
#
FROM alpine AS builder

ARG VERSION=61b24a369700c3d8248dd18fa9a524b778741454
RUN apk update \
  && apk add --no-cache --virtual .build-deps git make g++ \
  && git clone https://github.com/wangyu-/UDPspeeder.git udpspeeder \
  && cd udpspeeder \
  && git checkout $VERSION \
  && make OPT="-s" \
  && install speederv2 /usr/local/bin/udpspeeder \
  && cd - \
  && rm -r udpspeeder \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder /usr/local/bin/udpspeeder /usr/local/bin/

ENTRYPOINT ["udpspeeder"]
CMD ["--help"]
