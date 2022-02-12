#!/bin/sh
set -e
set -o pipefail

_is_exist_group() {
  getent group $1 &>/dev/null
}

_set_volume() {
  local mixer="$1"
  local volume="$2"
  if amixer -c $CARD_NUM -M sget $mixer &>/dev/null; then
    amixer -c $CARD_NUM -M sset $mixer unmute
    amixer -c $CARD_NUM -M sset $mixer ${volume}%
  fi
}

add_audio_group() {
  if ! _is_exist_group docker-audio; then
    addgroup -S -g $AUDIO_GID docker-audio && adduser airplay docker-audio
  fi
}

enable_sound() {
  _set_volume 'Master' 80
  _set_volume 'Headphone' 100
  _set_volume 'Speaker' 100
  _set_volume 'Line Out' 100
}

start_depends() {
  rm -f /run/dbus/dbus.pid /run/avahi-daemon/pid
  dbus-uuidgen --ensure
  dbus-daemon --system
  avahi-daemon --daemonize --no-rlimits --no-chroot
}

start_process() {
  exec su airplay -c shairport-sync "$@"
}

add_audio_group
enable_sound
start_depends
start_process
