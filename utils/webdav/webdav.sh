#!/bin/sh
set -e

_is_exist_group() {
  getent group $1 &>/dev/null
}

_is_exist_user() {
  id -u $1 &>/dev/null
}

_is_exist_group webdav || addgroup -S -g $GID webdav
_is_exist_user webdav || adduser -S -s /bin/ash -u $UID webdav
exec su webdav -c webdav "$@"
