#!/usr/bin/env bash

[ "$ENABLE_SSHD" = 1 ] || exit 0

# fix environment variables in ssh session
if [ ! -f /etc/profile.d/env_rust.sh ]; then
  cat <<- EOF > /etc/profile.d/env_rust.sh
	export RUSTUP_HOME=$RUSTUP_HOME \\
	  CARGO_HOME=$CARGO_HOME \\
	  PATH=$PATH \\
	  RUST_VERSION=$RUST_VERSION
	EOF
  info "fix environment variables in ssh session."
fi
