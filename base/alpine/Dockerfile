#
# Dockerfile for alpine base image
#

FROM alpine:3.24 AS rootfs

ARG TIMEZONES="\
  UTC \
  Etc/GMT+12 \
  Pacific/Pago_Pago \
  Pacific/Honolulu \
  Pacific/Marquesas \
  America/Anchorage \
  America/Los_Angeles \
  America/Phoenix \
  America/Costa_Rica \
  America/Bogota \
  America/La_Paz \
  America/St_Johns \
  America/Montevideo \
  America/Noronha \
  Atlantic/Cape_Verde \
  Atlantic/Reykjavik \
  Europe/Berlin \
  Africa/Johannesburg \
  Africa/Nairobi \
  Asia/Tehran \
  Asia/Yerevan \
  Asia/Kabul \
  Indian/Maldives \
  Asia/Colombo \
  Asia/Kathmandu \
  Asia/Thimphu \
  Indian/Cocos \
  Asia/Jakarta \
  #Asia/Hong_Kong \
  Asia/Taipei \
  Australia/Eucla \
  Asia/Tokyo \
  Australia/Darwin \
  Australia/Brisbane \
  Australia/Lord_Howe \
  Pacific/Noumea \
  Pacific/Tarawa \
  Pacific/Chatham \
  Pacific/Apia \
  Pacific/Kiritimati"
RUN apk add --no-cache --virtual .build-deps tzdata \
  && zoneinfo_dir=/usr/share/zoneinfo \
  && selected_zoneinfo_dir="$(mktemp -d)" \
  && for timezone in $TIMEZONES; do \
       source="$zoneinfo_dir/$timezone"; \
       destination="$selected_zoneinfo_dir/$timezone"; \
       mkdir -p "$(dirname "$destination")" && cp -L "$source" "$destination" || exit 1; \
     done \
  && apk del .build-deps \
  && mkdir -p "$zoneinfo_dir" \
  && cp -a "$selected_zoneinfo_dir/." "$zoneinfo_dir/" \
  && rm -r "$selected_zoneinfo_dir"

RUN apk add --no-cache ca-certificates
RUN apk del --no-cache musl-utils

FROM scratch
LABEL maintainer="pexcn <pexcn97@gmail.com>"

COPY --from=rootfs / /

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV TZ=Asia/Taipei
CMD ["/bin/sh"]
