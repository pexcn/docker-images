#
# Dockerfile for Rust language development environment
#

FROM pexcn/docker-images:dev
LABEL maintainer="pexcn <i@pexcn.me>"

#
# https://github.com/rust-lang/docker-rust/blob/10f1b7cab43bde8b4d6299aa4d91a895a0e5388d/1.64.0/bullseye/slim/Dockerfile
#
ENV RUSTUP_HOME=/usr/local/rustup
ENV CARGO_HOME=/usr/local/cargo
ENV PATH=/usr/local/cargo/bin:$PATH
ENV RUST_VERSION=1.64.0

RUN apt-get update \
  && apt-get install --no-install-recommends -y gcc libc6-dev \
  && case "$(dpkg --print-architecture)" in \
       amd64) rust_arch='x86_64-unknown-linux-gnu';; \
       arm64) rust_arch='aarch64-unknown-linux-gnu';; \
     esac \
  && wget "https://static.rust-lang.org/rustup/archive/1.25.1/${rust_arch}/rustup-init" \
  && chmod +x rustup-init \
  && ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION --default-host ${rust_arch} \
  && rm rustup-init \
  && chmod -R a+w $RUSTUP_HOME $CARGO_HOME \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# install components
RUN rustup component add rustfmt clippy

COPY rust.sh /usr/local/bin/
CMD ["rust.sh"]
