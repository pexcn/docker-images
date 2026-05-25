#
# Dockerfile for VoHive
#

#
# Build stage
#
FROM alpine:3.23 AS builder

ARG VOHIVE_VER=v1.1.8
RUN case $(apk --print-arch) in \
      x86_64) variant="amd64";; \
      aarch64) variant="arm64";; \
    esac \
  && wget https://github.com/pexcn/docker-images/releases/download/vohive/vohive_${VOHIVE_VER}_linux_${variant} -O /usr/local/bin/vohive \
  && chmod +x /usr/local/bin/vohive

COPY <<'EOF' /opt/vohive/config/config.yaml
server:
    debug: false
    port: :7575
web:
    username: admin
    password: admin
EOF

#
# Runtime stage
#
FROM alpine:3.23
LABEL maintainer="pexcn <pexcn97@gmail.com>"

RUN apk add --no-cache tzdata libqmi

COPY --from=builder /usr/local/bin/vohive /usr/local/bin/
COPY --from=builder /opt/vohive/config/config.yaml /opt/vohive/config/

RUN mkdir -p /opt/vohive/config /opt/vohive/data /opt/vohive/logs

WORKDIR /opt/vohive
ENTRYPOINT ["vohive"]
CMD ["-c", "/opt/vohive/config/config.yaml"]
