#!/usr/bin/env bash

[ "$ENABLE_SSHD" = 1 ] || exit 0

# fix environment variables in ssh session
if [ ! -f /etc/profile.d/env_go.sh ]; then
  cat <<- EOF >/etc/profile.d/env_go.sh
	export PATH=$PATH \\
	  GOTOOLCHAIN=$GOTOOLCHAIN \\
	  GOLANG_VERSION=$GOLANG_VERSION
	EOF
  info "fix environment variables in ssh session."
fi
