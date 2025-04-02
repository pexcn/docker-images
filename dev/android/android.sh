#!/usr/bin/env bash

[ "$ENABLE_SSHD" = 1 ] || exit 0

# fix environment variables in ssh session
if [ ! -f /etc/profile.d/env_android.sh ]; then
  cat <<- EOF > /etc/profile.d/env_android.sh
	export ANDROID_HOME=$ANDROID_HOME \\
	  PATH=$PATH
	EOF
  info "fix environment variables in ssh session."
fi
