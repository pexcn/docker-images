#
# Dockerfile for nginx
#

#
# Build stage
#
FROM alpine:3.18 AS builder

ARG QUICTLS_VER=openssl-3.0.9-quic1
RUN apk update \
  && apk add --no-cache --virtual .build-deps \
      git perl gcc make musl-dev linux-headers \
  && git clone https://github.com/quictls/openssl.git --branch $QUICTLS_VER --single-branch --recurse-submodules -j4 quictls-${QUICTLS_VER} \
  && cd quictls-${QUICTLS_VER} \
  && case $(apk --print-arch) in \
       x86_64) extra_args="enable-ec_nistp_64_gcc_128";; \
       *) extra_args="";; \
     esac \
  && ./Configure \
      --prefix=/usr \
      --openssldir=/etc/ssl \
      --libdir=lib \
      shared \
      no-weak-ssl-ciphers \
      enable-ktls \
      $extra_args \
  && make -j$(nproc) \
  && make install_sw \
  && make clean \
  && cd - \
  && rm -rf quictls-${QUICTLS_VER} \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

ARG NGINX_VER=1.25.1
ARG NGX_BROTLI_VER=6e975bcb015f62e1f303054897783355e2a877dc
ARG NGX_UPSTREAM_CHECK_VER=244e1cd436d496279b1649304b0985ae5621465c
ARG NGX_SUBS_FILTER_VER=e12e965ac1837ca709709f9a26f572a54d83430e
RUN apk update \
  && apk add --no-cache --virtual .build-deps \
      curl git patch make gcc g++ linux-headers pcre2-dev zlib-static \
  && curl https://nginx.org/download/nginx-${NGINX_VER}.tar.gz | tar zxv \
  && git clone https://github.com/google/ngx_brotli.git --recurse-submodules ngx_brotli \
  && git clone https://github.com/pexcn/ngx_upstream_check.git ngx_upstream_check \
  && git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git ngx_subs_filter \
  && cd ngx_brotli \
  && git checkout $NGX_BROTLI_VER \
  && cd - \
  && cd ngx_upstream_check \
  && git checkout $NGX_UPSTREAM_CHECK_VER \
  && patch -d ../nginx-${NGINX_VER} -p1 < check_1.20.1+.patch \
  && cd - \
  && cd ngx_subs_filter \
  && git checkout $NGX_SUBS_FILTER_VER \
  && cd - \
  && cd nginx-${NGINX_VER} \
  && ./configure \
      --prefix=/etc/nginx \
      --sbin-path=/usr/sbin/nginx \
      --modules-path=/usr/lib/nginx/modules \
      --conf-path=/etc/nginx/nginx.conf \
      --error-log-path=/var/log/nginx/error.log \
      --http-log-path=/var/log/nginx/access.log \
      --pid-path=/var/run/nginx.pid \
      --lock-path=/var/run/nginx.lock \
      --http-client-body-temp-path=/var/cache/nginx/client_temp \
      --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
      --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
      --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
      --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
      --user=nginx \
      --group=nginx \
      --with-file-aio \
      --with-threads \
      --with-http_sub_module \
      --with-http_addition_module \
      --with-http_auth_request_module \
      --with-http_dav_module \
      --with-http_flv_module \
      --with-http_gunzip_module \
      --with-http_gzip_static_module \
      --with-http_mp4_module \
      --with-http_random_index_module \
      --with-http_realip_module \
      --with-http_secure_link_module \
      --with-http_slice_module \
      --with-http_ssl_module \
      --with-http_stub_status_module \
      --with-http_sub_module \
      --with-http_v2_module \
      --with-http_v3_module \
      --with-stream \
      --with-stream_realip_module \
      --with-stream_ssl_module \
      --with-stream_ssl_preread_module \
      --with-cc-opt='-O3 -flto=auto' \
      --with-ld-opt='-s -l:libssl.a -l:libcrypto.a -l:libpcre2-8.a -l:libz.a' \
      --with-compat \
      --add-dynamic-module=/ngx_brotli \
      --add-dynamic-module=/ngx_upstream_check \
      --add-dynamic-module=/ngx_subs_filter \
  && make -j$(nproc) \
  && make install \
  && make clean \
  && cd - \
  && rm -rf nginx-${NGINX_VER} ngx_brotli ngx_upstream_check ngx_subs_filter \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine:3.18
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk update \
  && apk add --no-cache tzdata \
  && rm -rf /var/cache/apk/*

COPY --from=builder /etc/nginx/ /etc/nginx/
COPY --from=builder /etc/nginx/html/ /usr/share/nginx/html/
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder /usr/lib/nginx/modules/ /usr/lib/nginx/modules/

# create nginx user and group
ARG NGINX_GID=101
ARG NGINX_UID=$NGINX_GID
RUN addgroup -g $NGINX_GID -S nginx \
  && adduser -S -D -H -u $NGINX_UID -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx

# prepare nginx working directory
# manually created because the above `adduser` command is to be used as a reference for other dockerfiles
RUN mkdir /var/cache/nginx

# redirect log path to stdout/stderr
RUN mkdir /var/log/nginx \
  && ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log

# optimize directory structure
RUN rm /etc/nginx/*.default \
  && ln -s /usr/lib/nginx/modules /etc/nginx/modules

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
