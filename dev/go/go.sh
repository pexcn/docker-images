#!/usr/bin/env bash

# fix go environment variables in ssh session
[ "$ENABLE_SSHD" = 1 ] || exit 0
if [ ! -f /etc/profile.d/env_go.sh ]; then
  cat <<- EOF >/etc/profile.d/env_go.sh
	export PATH=/usr/local/go/bin:\$PATH \\
	  GOTOOLCHAIN=$GOTOOLCHAIN \\
	  GOLANG_VERSION=$GOLANG_VERSION
	EOF
  info "fix go environment variables in ssh session."
fi
