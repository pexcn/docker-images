#!/bin/sh
set -e
set -o pipefail

_is_exist_group() {
  getent group $1 &>/dev/null
}

_is_exist_user() {
  id -u $1 &>/dev/null
}

_set_volume() {
  local mixer="$1"
  local volume="$2"
  if amixer -c $CARD_NUM -M sget "$mixer" &>/dev/null; then
    echo "Mixer: $mixer -> ${volume}%"
    amixer -c $CARD_NUM -M sset "$mixer" unmute >/dev/null
    amixer -c $CARD_NUM -M sset "$mixer" ${volume}% >/dev/null
  fi
}

set_audio_group() {
  _is_exist_group airplay || addgroup -S -g $AUDIO_GID airplay
  _is_exist_user airplay || adduser -S -G airplay -s /bin/ash airplay
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

set_audio_group
enable_sound
start_depends
start_process
