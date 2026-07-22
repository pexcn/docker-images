#
# Dockerfile for Rust language development environment
#

FROM pexcn/docker-images:dev
LABEL maintainer="pexcn <pexcn97@gmail.com>"

#
# https://github.com/rust-lang/docker-rust/blob/40acf7919e2e27dc706918e42758a6f1c21e806b/stable/trixie/slim/Dockerfile
#
ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV PATH=/usr/local/cargo/bin:$PATH
ENV RUST_VERSION=1.97.1

ARG RUSTUP_VERSION=1.29.0
RUN apt-get update \
  && apt-get install --no-install-recommends -y gcc libc6-dev \
  && case "$(dpkg --print-architecture)" in \
       amd64) rust_arch='x86_64-unknown-linux-gnu';; \
       arm64) rust_arch='aarch64-unknown-linux-gnu';; \
     esac \
  && wget "https://static.rust-lang.org/rustup/archive/${RUSTUP_VERSION}/${rust_arch}/rustup-init" \
  && chmod +x rustup-init \
  && ./rustup-init -y --no-modify-path --profile minimal --default-toolchain "$RUST_VERSION" --default-host "${rust_arch}" \
  && rm rustup-init \
  && chmod -R a+w $RUSTUP_HOME $CARGO_HOME \
  && rustup --version \
  && cargo --version \
  && rustc --version \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# install components
RUN rustup component add rustfmt clippy

COPY rust.sh /usr/local/bin/
ENV DEV_INIT=/usr/local/bin/rust.sh
