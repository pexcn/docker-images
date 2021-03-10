#!/bin/sh

[ -e /root/.ssh/open-vm-tools ] || ssh-keygen -t ed25519 -f /root/.ssh/open-vm-tools -q -P ""
[ -e /root/.ssh/authorized_keys ] || touch /root/.ssh/authorized_keys

PUBLIC_KEY=$(cat /root/.ssh/open-vm-tools.pub)
grep -q -F "$PUBLIC_KEY" /root/.ssh/authorized_keys || echo $PUBLIC_KEY >> /root/.ssh/authorized_keys

exec /usr/bin/vmtoolsd
