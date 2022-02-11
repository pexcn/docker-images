#!/bin/sh
set -e
set -o pipefail

_is_exist_group() {
  getent group $1 &>/dev/null
}

add_audio_group() {
  if ! _is_exist_group docker-audio; then
    addgroup -S -g $AUDIO_GID docker-audio && adduser airplay docker-audio
    echo add-audio-group...
  fi
}

start_depends() {
  rm -f /run/dbus/dbus.pid /run/avahi-daemon/pid
  dbus-uuidgen --ensure
  dbus-daemon --system
  avahi-daemon --daemonize --no-rlimits --no-chroot
}

add_audio_group
start_depends
exec su airplay -c shairport-sync "$@"
