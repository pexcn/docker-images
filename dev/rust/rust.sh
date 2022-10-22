#!/usr/bin/env bash

# fix rust environment variables in ssh session
[ "$ENABLE_SSHD" = 1 ] || exit 0
if [ ! -f /etc/profile.d/env_rust.sh ]; then
  cat <<- EOF > /etc/profile.d/env_rust.sh
	export RUSTUP_HOME=$RUSTUP_HOME \\
	  CARGO_HOME=$CARGO_HOME \\
	  PATH=/usr/local/cargo/bin:\$PATH \\
	  RUST_VERSION=$RUST_VERSION
	EOF
  info "fix rust environment variables in ssh session."
fi
